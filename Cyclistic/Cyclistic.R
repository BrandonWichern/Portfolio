#load the necessary packages
library(tidyverse)  #data manipulation
library(lubridate)  #date functions
library(ggplot2)    #visualization

#check working directory
getwd() 

#set working directory
setwd("/Users/brand/Desktop/casestudy/csv")

#check working directory changed
getwd() 

#Load Data
tripdata_0622 <- read_csv("202206-divvy-tripdata.csv")
tripdata_0722 <- read_csv("202207-divvy-tripdata.csv")
tripdata_0822 <- read_csv("202208-divvy-tripdata.csv")
tripdata_0922 <- read_csv("202209-divvy-tripdata.csv")
tripdata_1022 <- read_csv("202210-divvy-tripdata.csv")
tripdata_1122 <- read_csv("202211-divvy-tripdata.csv")
tripdata_1222 <- read_csv("202212-divvy-tripdata.csv")
tripdata_0123 <- read_csv("202301-divvy-tripdata.csv")
tripdata_0223 <- read_csv("202302-divvy-tripdata.csv")
tripdata_0323 <- read_csv("202303-divvy-tripdata.csv")
tripdata_0423 <- read_csv("202304-divvy-tripdata.csv")
tripdata_0523 <- read_csv("202305-divvy-tripdata.csv")

#september data > "end_station_id" stored as num vice chr
#change end_station_id to chr
#df1$x1<−as.character(df1$x1)
tripdata_0922$end_station_id <- as.character(tripdata_0922$end_station_id)

# combine all monthly data frames into one data frame
all_trips <- bind_rows(tripdata_0622, tripdata_0722, tripdata_0822, tripdata_0922, tripdata_1022, tripdata_1122,
                       tripdata_1222,tripdata_0123,tripdata_0223, tripdata_0323, tripdata_0423, tripdata_0523)

#verify new single data frame
summary(all_trips)

#creating new field ride_length
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

#verify results
view(head(all_trips))

#converting ride_length to numeric
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))

#verify results
view(head(all_trips))

##########################################################
#Who rides for longer?

#minimum ride length        
min(all_trips$ride_length)
#Minimum: -621201

#assume any ride less than 30 seconds is not a ride
all_trips_2 <- all_trips[!(all_trips$ride_length < 30), ]

#verify results
summary(all_trips_2)

#compare average ride_length between casual and members: 
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = mean)
#1692 (28min) vs 747(12 min) - casual trips are longer on average

###########################################################
#When do they ride?

#Create columns for date, month, day, and year of each ride to determine usage
all_trips_2$date <- as.Date(all_trips_2$started_at)
all_trips_2$month <- format(as.Date(all_trips_2$date), "%m")
all_trips_2$day <- format(as.Date(all_trips_2$date), "%d")
all_trips_2$year <- format(as.Date(all_trips_2$date), "%Y")
all_trips_2$day_of_week <- format(as.Date(all_trips_2$date), "%A")

#verify results
summary(all_trips_2)
view(head(all_trips_2))
str(all_trips_2)

#organize days and view average ride_length by user type
all_trips_2$day_of_week <- ordered(all_trips_2$day_of_week, 
                                   levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

aggregate(all_trips_2$ride_length ~ all_trips_2$member_casual + all_trips_2$day_of_week, FUN = mean)
#both groups have longer average trips on the weekend

#writing output file
write.csv(all_trips_2, "/Users/brand/Desktop/casestudy/csv/all_trips.csv", row.names=FALSE)

###########################################################
#Average Duration by riders

#visualization - average duration by weekday
all_trips_2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarise(average_duration = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = average_duration/60, fill = member_casual)) +
  geom_col(position = "dodge")+
  labs(title="Average Ride Length by Weekday",
       caption="Data from: June 2022 to May 2023",
       x="Day of the Week",
       y="Average Ride Length (Minutes)",
       fill = "Rider Type")

#visualization - average duration by month
all_trips_2 %>% 
  group_by(member_casual, month) %>% 
  summarise(average_duration = mean(ride_length)) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month.abb[as.numeric(month)], y = average_duration/60 , fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Average Ride Length by Month",
       caption="Data from: June 2022 to May 2023",
       x="Month",
       y="Average Ride Length (Minutes)",
       fill = "Rider Type") +
  scale_x_discrete(limits = month.abb)

###########################################################
#Number of rides by riders

#visualization - number of rides by day of week
all_trips_2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides/1000 , fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Total Rides by Weekday",
       caption="Data from: June 2022 to May 2023",
       x="Day of the Week",
       y="Number of Rides (Thousands)",
       fill = "Rider Type")

#visualization - number of rides by month
all_trips_2 %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month.abb[as.numeric(month)], y = number_of_rides/1000 , fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Total Rides by Month",
       caption="Data from: June 2022 to May 2023",
       x="Month",
       y="Number of Rides (Thousands)",
       fill = "Rider Type") +
  scale_x_discrete(limits = month.abb)

###########################################################
#Bike Usage by riders

#visualization - bike usage by rider
all_trips_2 %>% 
  group_by(member_casual, rideable_type) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, rideable_type)  %>% 
  ggplot(aes(x = rideable_type, y = number_of_rides/1000 , fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Total Usage of Bike Types",
       caption="Data from: June 2022 to May 2023",
       x="Type of Bike",
       y="Number of Rides (Thousands)",
       fill = "Rider Type")

###########################################################
#Incorporating Climate Data

#JUN 2022 - MAY 2023 Average Temperature for Chicago
#Source: https://www.weather.gov/
temperature_data <- c(32.6, 34.4, 39.2, 52.6,	63.3, 75, 77.7, 76.8, 70,	56.3,	44.1,	29.5)

#visualization - rides per month with average monthly temperature data
all_trips_2 %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month.abb[as.numeric(month)], y = number_of_rides/1000 , fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Total Rides by Month vs Monthly Average Temperature",
       caption="Data from: June 2022 to May 2023",
       x="Month",
       y="Number of Rides (Thousands)",
       fill = "Rider Type") +
  scale_x_discrete(limits = month.abb) +
  geom_point(aes(y=temperature_data[as.numeric(month)] * 5), color="red") +
  scale_y_continuous(sec.axis=sec_axis(~.*0.2,name="Temperature (F)"))

##########################################################



