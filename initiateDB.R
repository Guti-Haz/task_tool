pacman::p_load(RSQLite,DBI,rstudioapi,glue,magrittr,data.table)
setwd(dirname(getSourceEditorContext()$path))
# create db ----
if("db.sqlite"%in%list.files()==T) unlink("db.sqlite")
db=dbConnect(RSQLite::SQLite(),"db.sqlite")
# create table ----
tableName="timeline"
colName=c("project",
          "importance",
          "sub_project",
          "task",
          "task_dependency",
          "duration_week",
          "startDate",
          "endDate")
colType=c("TEXT",
          "TEXT",
          "TEXT",
          "TEXT",
          "TEXT",
          "INTEGER",
          "TEXT",
          "TEXT")
colSql=paste0(colName," ",colType)%>%paste0(collapse=", ")
q=glue("CREATE TABLE {tableName} ({colSql})")
dbExecute(db,q)
# # add rows ----
# testData=data.table(project="STR prioritization",
#              importance="high",
#              sub_project="EOI",
#              task="scrap",
#              duration_week=10,
#              startDate="2019-01-01",
#              endDate="2020-01-01")
# dbAppendTable(db,tableName,testData)
# disconnect ----

