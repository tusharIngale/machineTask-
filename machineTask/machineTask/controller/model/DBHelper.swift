//
//  DBHelper.swift
//  machineTask
//
//  Created by Mac on 27/08/21.
//

import Foundation

import SQLite3

class DBHelper {
   //MARK: Global Variables

    static let shared = DBHelper()
    let tableName = "Venue"
    
    private init() {
        db = openDatabase()
        createTable()
    }
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    
    //MARK: Create DB
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at \(fileURL.path)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS \(tableName)(Id TEXT PRIMARY KEY,name TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\(tableName) table created.")
            } else {
                print("\(tableName) table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    //MARK: Insert Into DB
    func insert(venueObj: Venue) {
        let venues = read()
        for venue in venues {
            if venue.id == venueObj.id {
                return
            }
        }
        let insertStatementString = "INSERT INTO \(tableName) (Id, name) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, ((venueObj.id) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ((venueObj.name) as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    //MARK: Read from DB
    func read() -> [Venue] {
        let queryStatementString = "SELECT * FROM \(tableName);"
        var queryStatement: OpaquePointer? = nil
        var venueObj : [Venue] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                venueObj.append(Venue(id: id, name: name))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return venueObj
    }
    
    func readVenue(venueObject: Venue) -> [Venue] {
        let queryStatementString = "SELECT * FROM \(tableName)  WHERE Id = '\(venueObject.id)';"
        var queryStatement: OpaquePointer? = nil
        var venueObj : [Venue] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                venueObj.append(Venue(id: id, name: name))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return venueObj
    }
    
    //MARK: Delete from DB
    func deleteByID(venueObject: Venue) {
        if self.readVenue(venueObject: venueObject).count != 0 {
            let deleteStatementStirng = "DELETE FROM \(tableName) WHERE Id = '\(venueObject.id)';"
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(deleteStatement, 1, ((venueObject.id) as NSString).utf8String, -1, nil)
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
        }
    }
    
}
