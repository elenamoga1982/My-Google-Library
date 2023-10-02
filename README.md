# My Google Library

This is my final project for the Udacity "iOS Developer Nanodegree" Program:

# Table of Contents
* App Description
* Project Details (user interface, networking, data persistence)
* App Requirements

## App Description
This app allows the users to make a personalized library from Google Books. The user can search books by author, title or isbn. The result of searching is displayed in the same table view. You can select any book from results to see a detail view of that book. The detail view includes: title and book's cover image, author, language, publisher and published date, number of pages and Isbn. On the same view, the user has the option to save the book information in the book list or return to the search result view. All the saved books are displayed in the book list view. The user can sort the saved books by author or by title. Selecting a saved book will open a detail view of this book as well. A book can be deleted from user's own book list by swiping left on the respective book cell. Furthermore, the user can search in its own book list by author, title or Isbn. That search functionality can be enabled by swiping down the book list and can be hidden by swiping it up.

## Project Details

### User Interface
* Three main View Controllers (Search books View Controller, My books View Controller, Book Info View Controller)
* The View Controllers mentioned above are Table View based
* Both Book List and Book Search are embedded in a Navigation View Controller to enable back and forth navigation to Book Detail View
* Save action is used to save books in your own library
* Books can be sorted by author or by title via Segmented Control
* Possibility for online book search and searching in own book list via UISearchBar
* Saved books can be deleted by user from its own list
 
### Networking
* The app downloads the information (title and book's cover image, author, language, publisher and published date, number of pages and Isbn) from Google Books API REST service      
* Meanwhile the search is in progress, it's shown an Activity Indicator
* In case of connection error, an alert will be displayed
* In case of no results, an alert will be displayed
* All the networking code is encapsulated in a class
 
### Data Persistence
* Books added to My book library are stored in Core Data
* The constraints prevent book duplicates in the personal book library
* Core Data Helper uses a separate structure
* The book sorting by author or title is saved in NSUserDefaults

## App Requirements
The app uses the public Google Books API with no API Key requirement
