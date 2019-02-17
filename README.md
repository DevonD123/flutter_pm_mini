# app checklist

- [X] pass back the PassBack data type from details screen and set values accordingly
    -> in the screen it is returned to abstract it away from the function where check if shoulddelete or should edit and do actions accordingly
- [X] add a add helpers/other ppl to task -> in the todo aswell as the inputs (and todo constructors) --> not constructor set after
- [X] connect to firebase
- [X] add firbase auth -> make sure the user always passes the user id string in correctly (edit rights)
- [X] add todolist in firebase (storing data not just login) [[store under user login id]]
- [X] add save hooks to db -> + auth hooks (only logged in can use)
- [X] add invite system? maybe firebase cloud functions to email? ----> just in app-
- [X] to todo details add more content (listview for users) - just text with \n join
- [X] ADD TRIM TO INPUTS AND MORE VALIDATION
- [X] ADD ON SIGNUP CREATE A COLLECTION WITH USERID AND TODOS
- [X] ADD ERROR HANDLING AND POSSIBLE RESYNC (minimal err handling)
- [X] add activity indicators and error indicators for main screen
- [X] add perm login 
- [X] add reset pass email
- get screenshots etc... desc... make accounts and deploy
- [ ] set up fb for ios (giving error)
- [ ] add sort for completed ---> make sure it works for the second fetched todos aswell ---> changed fetch to pass the list to the helper fetch so only 1 sort and no 2 part view set
- [X] make sure to trim text if exeeds length

- [] bonus: add offline notification/maybbee offline support for some things/resync when online
- [] bonus: add email conf (and screen for non confirmed/warning msg)
- [] bonus: add request status for helpers
- b) [] bonus: add time based sched not just day
- c) [] bonus: add notifications ++ maybe email/text (look at plugins and if $$??)
- [] bonus: add task owner name for non owners (change todo data obj to hold username and all edit/create)
- [] bonus bonus: add individual checkoffs for each person added to a task
- [] mayybbbe bonus: add resyncs on a timer/stream for firestore to get data all the time ($$??)

deployed to ios app store
--> migrating to android x then submit to google play