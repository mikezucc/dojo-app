//
//  SocketAckMap.swift
//  SocketIO-Swift
//
//  Created by Erik Little on 4/3/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

struct SocketAckMap {
    private var acks = [Int: AckCallback]()
    private var waiting = [Int: Bool]()
    
    mutating func addAck(ack:Int, callback:AckCallback) {
        waiting[ack] = true
        acks[ack] = callback
    }
    
    mutating func executeAck(ack:Int, items:[AnyObject]?) {
        let callback = acks[ack]
        waiting[ack] = false
        
        dispatch_async(dispatch_get_main_queue()) {
            callback!(items)
        }
        
        acks.removeValueForKey(ack)
    }
    
    mutating func timeoutAck(ack:Int) {
        if waiting[ack] != nil && waiting[ack]! {
            acks[ack]?(["NO ACK"])
        }
        
        acks.removeValueForKey(ack)
        waiting.removeValueForKey(ack)
    }
}
