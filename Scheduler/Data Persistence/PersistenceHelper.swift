//
//  PersistenceHelper.swift
//  Scheduler
//
//  Created by Alex Paul on 1/23/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

public enum DataPersistenceError: Error {
  case propertyListEncodingError(Error)
  case propertyListDecodingError(Error)
  case writingError(Error)
  case deletingError
  case noContentsAtPath(String)
}

protocol DataPersistenceDelegate: AnyObject {
    func didDeleteItem<T>(_ persistenceHelper:DataPersistence<T>, item: T)
}

typealias Writeable = Codable & Equatable
// typealias = Codable & Equatable

// DataPersistence is now type constrained to only work with Codable types
// T is a placeholder
class DataPersistence<T: Writeable> {
  
  private let filename: String
  
  private var items: [T]
    
    // step 2: custom delegation - defining a reference property that will be registered at the object listening for notifications
    // we use weak to break strong reference cycle between the delegate object and the DataPersistence class
    
    weak var delegate: DataPersistenceDelegate?
      
  public init(filename: String) {
    self.filename = filename
    self.items = []
  }
  
  private func saveItemsToDocumentsDirectory() throws {
    do {
      let url = FileManager.getPath(with: filename, for: .documentsDirectory)
      let data = try PropertyListEncoder().encode(items)
      try data.write(to: url, options: .atomic)
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Create
  public func createItem(_ item: T) throws {
    _ = try? loadItems()
    items.append(item)
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Read
  public func loadItems() throws -> [T] {
    let path = FileManager.getPath(with: filename, for: .documentsDirectory).path
     if FileManager.default.fileExists(atPath: path) {
       if let data = FileManager.default.contents(atPath: path) {
         do {
           items = try PropertyListDecoder().decode([T].self, from: data)
         } catch {
          throw DataPersistenceError.propertyListDecodingError(error)
         }
       }
     }
    return items
  }
  
  // for re-ordering, and keeping date in sync
  public func synchronize(_ items: [T]) {
    self.items = items
    try? saveItemsToDocumentsDirectory()
  }
  
  // Update
    @discardableResult // silences the warning if the return value is not used by the caller
    public func update(_ oldItem: T, with newItem: T) -> Bool {
        if let index = items.firstIndex(of: oldItem){
            let result = update(newItem, at: index)
            return result
        }
        return false
    }
    
    public func update(_ item: T, at index: Int)-> Bool {
        items[index] = item
        do {
            try saveItemsToDocumentsDirectory()
            return true
        } catch {
            return false
        }
    }
  
  // Delete
  public func deleteItem(at index: Int) throws {
    let deletedItem = items.remove(at: index)
    do {
      try saveItemsToDocumentsDirectory()
        // step 3: custom delegation - use delegate regerence to notify observer of deletion
        delegate?.didDeleteItem(self, item: deletedItem)
    } catch {
      throw DataPersistenceError.deletingError
    }
  }
  
  public func hasItemBeenSaved(_ item: T) -> Bool {
    guard let items = try? loadItems() else {
      return false
    }
    self.items = items
    if let _ = self.items.firstIndex(of: item) {
      return true
    }
    return false
  }
  
  public func removeAll() {
    guard let loadedItems = try? loadItems() else {
      return
    }
    items = loadedItems
    items.removeAll()
    try? saveItemsToDocumentsDirectory()
  }
}
