# README #

###**Quick Summary**###
This Application is a book library where user can add or remove a book from the library. User can also search and apply filters to the book library. The app even shows details of each book and the user can even checkout the book as well as share the book via social media. 

### How do I get set up? ###
** # Summary of set up #**
###**BookListViewController**###
* This is the app's first screen where it shows a list of books if available on the server if not empty.
* User can add a book to the library by pressing the add button on top left.
* User can delete a book by swiping from right to left.
* User can apply filters(filter at top right) to the list of books and search for a book.
* User can see details of a book when tapped on any book.
* User can pull the table to refresh in-order to retrieve new books.
###**AddBookViewController**###
* This screen shows a list of fields for adding a new book to the library.
* The mandatory fields are Book Title and Book Author. If they are not filled it throws an alert for missing fields.
* It has other fields like categories(tags) and publisher.
###**BookDetailViewController**###
* This screen shows the details of a book.
* Here a user can checkout the book by tapping checkout button and user has to enter his/her name.
* User can share book details via social media.
###**FilterViewController**###
* This is an additional feature for the app.
* It has filters, where a user can select a field ("title" or "author") and can have list of books in ascending or descending order.
* By default title and ascending are selected.
* It has a checkout switch, once turned on, shows only list of books that are checked out or else all the books are shown (checkout or not checkout).
* It has reset filter where it resets all the filters and data back to normal.
* It has a delete all button where one can delete all books from the library. 
###**Dependencies**###
* AFNetworking Library
* MBProgressHUD
###**How to run tests**###
* To run all tests at once go to Product->Test or command + u
* To run individual tests go to project navigator and select show test navigator where you will be shown a list of test methods. 
###**Deployment instructions**###
* Requires iOS 7.0 and later