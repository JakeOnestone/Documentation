*   Create new address books/calendars in the web interface and not with a client (Evolution, ...)
*   Connecting a client:
    *   Evolution (3.28.4):  
        Calendar:
        *   go to calendar page
        *   File -> New -> Calendar
        *   type = "CalDAV"
        *   name and color will be set by Radicale
        *   address = "http://server:port/user" (e.g. "alice")
        *   user = "user" (e.g. "alice")
        *   Search calendar
        *   (enter password)
        *   select calendar
        *   OK
        *   OK

        Contacts:
        *   go to contacts page
        *   File -> New -> Address book
        *   type = "CardDAV"
        *   name will be set by Radicale
        *   address = "http://server:port/user" (e.g. "alice")
        *   user = "user" (e.g. "alice")
        *   Search address books
        *   (enter password)
        *   select calendars
        *   OK
        *   OK
    *   DAVdroid (1.11.5-ose):
        *   Login with URL and username
        *   URL = "http://server:port/"
        *   User = "user" (e.g. "alice")
        *   Password = "password"
        *   Login
