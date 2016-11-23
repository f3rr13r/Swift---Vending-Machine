//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Harry Ferrier on 6/7/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//



import Foundation
import UIKit



////////////////////////////
/////// PROTOCOLS /////////
///////////////////////////


protocol VendingMachineType {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection : ItemType] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection : ItemType])
    
    func vend(_ selection: VendingSelection, quantity: Double) throws
    func itemForCurrentSelection(_ selection: VendingSelection) -> ItemType?
    func deposit(_ amount: Double)
}


/**/

protocol ItemType {
    var price: Double { get }
    var quantity: Double { get set }
}




////////////////////////////
/////// ERROR TYPES ///////
///////////////////////////



enum InventoryError: Error {
    case invalidResource
    case conversionError
    case invalidKey
}


enum VendingMachineError: Error {
    case invalidSelection
    case outOfStock
    case insufficientFunds(required: Double)
}






////////////////////////////
///// HELPER CLASSES //////
///////////////////////////




class PlistConverter {
    class func getDictionaryFromFile(_ resource: String, ofType type: String) throws -> [String : AnyObject] {
        
        // Guard statement #1 - NSBundle to file that we need.
        guard let pathToPlist = Bundle.main.path(forResource: resource, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        // Guard statement #2 - NSDictionary to access contents of the 'path' file
        guard let dictionary = NSDictionary(contentsOfFile: pathToPlist),
            
        // Downcast 'dictionary' to meet the [key: String : Value: AnyObject] critera
        let castDictionary = dictionary as? [String : AnyObject] else {
            throw InventoryError.conversionError
        }

        return castDictionary
        
    }
}


/**/



class InventoryUnarchiver {
    class func vendingInventoryFromDictionary(_ dictionary: [String : AnyObject]) throws -> [VendingSelection : ItemType] {
    
        var inventory: [VendingSelection : ItemType] = [:]
        
        for (key, value) in dictionary {
            if let itemDict = value as? [String : Double],
            let price = itemDict["price"],
                let quantity = itemDict["quantity"] {
                
                let item = VendingItem(ItemPrice: price, ItemQuantity: quantity)
                
                guard let key = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidKey
                }
                
                inventory.updateValue(item, forKey: key)
                
            }
        }
        
        return inventory
        
    }
}








////////////////////////////
///// CONCRETE TYPES //////
///////////////////////////


enum VendingSelection: String {
    case Gum
    case SportsDrink
    case FruitJuice
    case Water
    case PopTart
    case CandyBar
    case Wrap
    case Sandwich
    case Cookie
    case Chips
    case DietSoda
    case Soda
    
    func icon() -> UIImage {
        if let image =  UIImage(named: self.rawValue) {
            return image
        } else {
            return UIImage(named: "Default")!
        }
    }
    
}



/**/



struct VendingItem: ItemType {
    let price: Double
    var quantity: Double
    
    init(ItemPrice: Double, ItemQuantity: Double) {
        self.price = ItemPrice
        self.quantity = ItemQuantity
    }
}



/**/



class VendingMachine: VendingMachineType {
    let selection: [VendingSelection] = [.Gum, .SportsDrink, .FruitJuice, .Water, .PopTart, .CandyBar, .Wrap, .Sandwich, .Cookie, .Chips, .DietSoda, .Soda]
    
    var inventory: [VendingSelection : ItemType]
    var amountDeposited: Double = 10.00
    
    required init(inventory: [VendingSelection : ItemType]) {
        self.inventory = inventory
    }
    
        func vend(_ selection: VendingSelection, quantity: Double) throws {
        // Add Code
            guard var item = inventory[selection] else {
                throw VendingMachineError.invalidSelection
            }
            
            guard item.quantity > 0 else {
                throw VendingMachineError.outOfStock
            }
            
            item.quantity -= quantity
            inventory.updateValue(item, forKey: selection)
            
            let totalPrice = item.price * quantity
            if amountDeposited >= totalPrice {
                amountDeposited -= totalPrice
            } else {
                let amountRequired = totalPrice - amountDeposited
                throw VendingMachineError.insufficientFunds(required: amountRequired)
            }
        }
    
    
        func itemForCurrentSelection(_ selection: VendingSelection) -> ItemType? {
            return inventory[selection]
        }
    
        
        func deposit(_ amount: Double) {
        // Add Code
            amountDeposited += amount
        }
    }
















