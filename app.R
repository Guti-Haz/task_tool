setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("loadVar.R")
source("initiateDB.R")
ui=fluidPage(
    useShinyjs(),
    fluidRow(
        titlePanel("Sprint"),
        column(3,
               wellPanel(
                   textInput("project","Project"),
                   uiOutput("ui_taskDependency"),
                   selectizeInput('analyst',glue('Analyst ({length(analystList)})'),analystList,multiple=T,options=optPlaceholder),
                   textInput("task","Task"),
                   dateInput("startD","Start date"),
                   sliderInput("duration_week","Duration (week)",1,10,3),
                   actionButton("submit","Submit"),
                   actionButton("reset","Reset")
               )
        ),
        column(9,
               tabsetPanel(
                   tabPanel("timevis",
                            br(),
                            timevisOutput("gantt")),
                   tabPanel("datatable",
                            br(),
                            DT::dataTableOutput("timelineDT"))
               )
        )
    )
)
server=function(input,output,session) {
    rv=reactiveValues(state=F)
    
    observeEvent(input$project,{
        conn=dbConnect(RSQLite::SQLite(),"db.sqlite")
        dt=dbReadTable(conn,"timeline")%>%setDT
        dbDisconnect(conn)
        if(nrow(dt)>0){
            setSelection("gantt",dt[project==input$project,id])
        }
        output$ui_taskDependency=renderUI({
            if(dt[project==input$project,.N]>0) {
                choices=dt[project==input$project,c("",sort(unique(task)))]
                UI=selectizeInput("task_dependency",glue("Dependency ({length(choices)-1})"),choices,options=optPlaceholder)
                rv$state=T
                return(UI)
            } else {
                ""
            }
        })
        if(nrow(dt)>0){
            updateSelectizeInput(session,"analyst",selected=dt[project==input$project,unlist(str_split(analyst,","))])
        }
    })
    
    observe({
        if(rv$state){
            if(!is.null(input$task_dependency)){
                if(input$task_dependency!=""){
                    conn=dbConnect(RSQLite::SQLite(),"db.sqlite")
                    dt=dbReadTable(conn,"timeline")%>%setDT
                    dbDisconnect(conn)
                    updateDateInput(session,"startD",value=dt[project==input$project&task==input$task_dependency,date(endDate)])
                } else {
                    updateDateInput(session,"startD",value=initialDate)
                }
            }
        } else {
            updateDateInput(session,"startD",value=initialDate)   
        }
    })
    
    observeEvent(input$submit,{
        conn=dbConnect(RSQLite::SQLite(),"db.sqlite")
        endDate=as.character(date(as.character(input$startD))+(input$duration_week*7))
        newData=data.table(id=floor(runif(1,1e6,1e7)),
                           analyst=paste0(input$analyst,collapse=","),
                           project=input$project,
                           task=input$task,
                           task_dependency=input$task_dependency,
                           duration_week=input$duration_week,
                           startDate=as.character(input$startD),
                           endDate=endDate)
        dbAppendTable(conn,"timeline",newData)
        dbDisconnect(conn)
        sapply(c("analyst","project","task"),shinyjs::reset)
        rv$state=F
    })
    
    observeEvent(input$reset,{
        sapply(c("analyst","project","task"),shinyjs::reset)
        updateDateInput(session,"startD",value=initialDate)
    })
    
    dt=eventReactive(input$submit,{
        conn=dbConnect(RSQLite::SQLite(),"db.sqlite")
        dt=dbReadTable(conn,"timeline")
        dbDisconnect(conn)
        return(dt)
    },ignoreNULL = F)
    
    output$timelineDT=DT::renderDataTable({
        datatable(dt())
    })
    
    output$gantt=renderTimevis({
        data=dt()%>%
            setDT%>%
            .[,.(id=id,
                 start=startDate,
                 end=endDate,
                 group=project,
                 content=task)]
        groups=dt()%>%
            setDT%>%
            .[,.(id=project,
                 content=project)]%>%
            unique
        timevis(data=data,groups=groups)
    })
}
shinyApp(ui=ui,server=server)
