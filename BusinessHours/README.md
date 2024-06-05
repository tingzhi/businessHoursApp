# BusinessHours iOS App

## Logic to determine accordion text

### Open until {time}
When the store is open, and it only has one time block for that day.

Or when the store is open, and the app is showing last time block for that business day(which may carryover to the next day)

### Open until {time}, reopens at {next time block}
This is the case when the store briefly close during a business day.

### Opens again at {time}
The store is closed and the next open period begins within 24 hours.

### Opens {day} {time}
The store is closed and the next open period begins greater than 24 hours in the future.

## Assumptions
- If a given weekday does not have business hours, the store is closed.
- Business hour block has minimum increment of 1 hour. For example: 8:00AM - 8:30AM is not allowed. 8:00AM - 9:00AM is.

## Pointers on the algorithm
In my algorithm, there are carryoverPrevious time block and carryoverNext time block. These are used to handle business hours that corssover day boundary. For example: 

if we have

Tuesday 3pm - 12am

Wednesday 12am - 2am

Tuesday has a carryoverNext time block of (Wednesday 12am - 2am). This block will be used to calculate correct business hours for Tuesday.

Wednesday has a carryoverPrevious time block of (Wednesday 12am - 2am). This block will be omitted when displaying full hours.

The threshold for the end time of carryover time block is set to be 6AM. For example: given the above example, if we have Wednesday 12am - 7am, this is not considered part of Tuesday anymore. 

## Improvements
- Highlight current business hours when viewing full hours, paying attention to carryover time blocks.
- Customized background using radial gradient

