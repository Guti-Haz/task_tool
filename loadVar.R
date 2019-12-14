pacman::p_load(RSQLite,
               DBI,
               magrittr,
               data.table,
               shiny,
               DT,
               lubridate,
               timevis,
               shinyjs,
               glue,
               stringr)
analystList=sort(c("HAZ","JIUN","HANI","YAN"))
optPlaceholder=list(
  placeholder='Select options below',
  onInitialize=I('function() { this.setValue(""); }')
)
initialDate=date(today())
