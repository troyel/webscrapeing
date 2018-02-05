library("rvest")
require(reshape2)
require(chron)

url <- "https://www.yr.no/sted/Norge/Oslo/Oslo/Oslo_(Blindern)_m%C3%A5lestasjon/almanakk.html?dato="

startDate <- as.Date(as.character(20160101), "%Y%m%d")

dates <- seq.Date(startDate, Sys.Date(), by = "days" )
dates <- data.frame(dates)
weather <- ""

#Scrape 1
#Get hour by hour detailed weather data starting 01.01.2016 to todays date

print("starting loop")
for (i in 1:nrow(dates)){ #nrow(dates)
  population <- paste0(url,dates[i,]) %>%
    read_html() %>%
    html_nodes(xpath='//*[@id="ctl00_ctl00_contentBody"]/div[2]/div[2]/div[3]/table') %>%
    html_table(fill = T)
  population <- data.frame(population)
  population <- population[-1,]
  population[c("Date")] <- as.character(dates[i,])  
  population <- data.frame(population)
  if (i == 1){
    weather <- population}
  else { 
    weather <- rbind(weather, population)}
  print(paste("loop", i, "of", nrow(dates)))  
}

write.csv2(weather,"weather.csv", quote = T)


# Part 2 - format data and get total daily rain
weather <- as.data.frame(read.csv2("weather.csv")) 

head(weather)
weather2 <- as.data.frame(weather) 

tidspunkt <- colsplit(weather$Tidsp.," ", names = c("dag", "tid"))

weather2$Tidsp. <- tidspunkt$tid

for (i in 1:nrow(weather2)){
  if (as.numeric(weather2$Tidsp.[i]) < 10) {
  weather2$Tidsp.[i] <- paste0("0",weather2$Tidsp.[i],":00:00")}
  else {  weather2$Tidsp.[i] <- paste0(weather2$Tidsp.[i],":00:00")}
}

weather2$timedate <- paste(weather2$Date, weather2$Tidsp.)

#scrape 2
# get total day rain weather data

print("starting loop")
totaldaydata <- ""

for (i in 1:nrow(dates)){ #nrow(dates)
  dayweather <- paste0(url,dates[i,]) %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="ctl00_ctl00_contentBody"]/div[2]/div[2]/div[2]/div[2]/div[2]/div/ul/li[2]') %>%
  html_text(trim = T) %>%
  strsplit(split = '\n')
  dayweather <- as.data.frame(dayweather)
  dayweather[c("Date")] <- as.character(dates[i,])  
  names(dayweather) <- c("rain", "Date")
  dayweather <- data.frame(dayweather)
  if (i == 1){
    totaldaydata <- dayweather}
  else { 
    totaldaydata <- rbind(totaldaydata, dayweather)}
  print(paste("loop", i, "of", nrow(dates)))  
}

temp <- colsplit(totaldaydata[,1], " ", c("1", "2" ,"3") ) 

totaldaydata$rain <- temp$`2`
