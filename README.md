This project was created for the purpose of serving as an experiment in using progressive migration with the module Encrypted-Core-Data (ECD). Currently, ECD does not respond to the signals being sent to progressively migrate and this project will serve as the place to experiment/tinker with in hopes of solving this problem.

HOW TO USE THIS PROJECT:
This project has 4 interfaceable objects for the user the use.

The switch is used to allow the user to control whether or not they want database to be encrypted. It is advantageous to have this functionality as it makes it easier to look into the sqlite file with software such as SQLiteManager when the file is not encrypted. The rest of the buttons are self-explanatory.

This project expects the user to ALWAYS initialize core data using the original data model (ie. ECD_Migration.xcdatamodel), and to have the corresponding NSManagedObject classes built for the data model version being used.

Once this is true, the user may click on the 'Initialize CoreData' button to create the database. In order to test migration, the user must then choose which data model version they wish to use, replace the corresponding NSManagedObject classes.

Afterwards, the user must go to the IBAction initializeCoreDataAction and comment out [self initializeDefaultData] and [self verifyInitialData] before running the app. Notice this time, the button 'Initialize CoreData' will be disabled. The user will then press 'Start Migration' and can then watch the console for error logs.

A test case has been written for each model. Please visit the IBAction startMigrationAction and read the comments there to enable the proper test cases.

Please take the time to skim through the code if compilation arises as comments have been placed in appropriate places to remind the user what to do depending on test cases being run. 