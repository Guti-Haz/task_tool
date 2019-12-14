pacman::p_load(RSQLite,DBI,rstudioapi,glue,magrittr,data.table)
setwd(dirname(getSourceEditorContext()$path))
# create db
if("db.sqlite"%in%list.files()==T) unlink("db.sqlite")
db=dbConnect(RSQLite::SQLite(),"db.sqlite")
# create table
tableName="timeline"
colName=c("id",
          "analyst",
          "project",
          "task",
          "task_dependency",
          "duration_week",
          "startDate",
          "endDate")
colType=c("INTEGER",
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
# disconnect
dbDisconnect(db)
