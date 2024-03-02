//Copyright © 2024 Chales Kerr. All rights reserved.

import Foundation
import Network

class Connection : NSObject {
    @IBOutlet weak var mediaController:MediaWindowController!

    @objc dynamic var connected:Bool = false
    var nwConnection:NWConnection? = nil
    
    var incomingPacket: Data = Data()
    var idleTimer:Timer? = nil
    var myHandle = "Media Client"


    // =============================================================================================================
    // Packet related items
    // =============================================================================================================

    // ===============================================================================================================
    private func sendIdentification(handle:String) -> Bool {
        var ident = Data(count: IDENTPACKETSIZE)
        ident.packetID = IDENTPACKET
        ident.packetLength = Int32(IDENTPACKETSIZE)
        ident.identHandle = handle
        return self.send(data: ident)
    }

    // ================================================================================================================
    func processPacket(data:Data) {
        let packetid = data.packetID
        switch (packetid) {
            case NOPPACKET:
                //Swift.print("Process NOP")
                let respond = data.nopRespond
                if (respond) {
                    //Swift.print("Send NOP")
                    var newdata = Data(count: NOPPACKETSIZE)
                    newdata.packetLength = Int32(NOPPACKETSIZE)
                    newdata.packetID = NOPPACKET
                    _ = self.send(data: newdata)
                }
                
            case SYNCPACKET:
               // Swift.print("Process Sync")
               let frame = data.syncFrame
                mediaController.sync(frame: frame)
  
                
            case LOADPACKET:
                //Swift.print("Process Load")
               let moviename = data.movieName
                mediaController.loadMovie(moviename: moviename)
                 
            case PLAYPACKET:
               // Swift.print("Process Play")
                let state = data.playState
                let frame = data.playFrame
                mediaController.playMovie(state: state, frame: frame)
            
                
            case SHOWPACKET:
                //Swift.print("Process Show")
                let state = data.showState
                mediaController.setShow(state: state)
                
            default:
                Swift.print("unknown packet to process")
                break
        }
    }

    // =============================================================================================================
    // Timer related items
    // =============================================================================================================

    // ===============================================================================================================
    func scheduleTimer() {
        self.idleTimer?.invalidate()
        self.idleTimer = nil
        
        self.idleTimer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: false, block: { _ in
            
            // If this happens, we haven't heard from the server
            self.idleTimer?.invalidate()
            self.idleTimer = nil
            Swift.print("Timer expired, calling stop")
            self.stop(error: nil)
        })
    }

    
    // =============================================================================================================
    // Connection related items
    // =============================================================================================================

    // ==============================================================================================================
    func stop(error: Error?) {
        Swift.print("In Connection.stop(error:) setting connected to false")
        self.nwConnection?.cancel()
        self.nwConnection?.stateUpdateHandler = nil
        
        self.idleTimer?.invalidate()
        self.idleTimer = nil
        if self.connected != false {
            self.connected = false
        }
    }
    // ==============================================================================================================
    func stop() {
        Swift.print("In Connection.stop) setting connected to false")
        self.idleTimer?.invalidate()
        self.idleTimer = nil
        self.nwConnection?.cancel()
        self.nwConnection?.stateUpdateHandler = nil
        if self.connected != false {
            self.connected = false
        }
    }
    // ===============================================================================================================
    func connectionDidEnd() {
        Swift.print("In Connection.connectionDidEnd()")
        self.stop(error:nil)
    }
    
    // ===============================================================================================================
    func connectionDidFail(error:Error) {
        Swift.print("In Connection.connectionDidFail(error:")
        self.stop(error:error)
    }

    // ===============================================================================================================
    func stateDidChange(to state:NWConnection.State) {
        switch state {
            case .waiting(let error):
                connectionDidFail(error: error)
            case .ready:
                if connected != true {
                    connected = true
                    // We need to send out identifiction
                    Swift.print("Sending handle: \(myHandle)")
                    _ = self.sendIdentification(handle: myHandle)
                    DispatchQueue.main.async{
                        _ = self.setupRead()
                    }
                }
            case .failed(let error):
                connectionDidFail(error: error)
            case .setup:
                break
            case .cancelled:
                break
            default:
                break
        }
    }

    // ==============================================================================================================
    func connect(serverIP:String,serverPort: String) -> Bool {
        guard !serverIP.isEmpty, !serverPort.isEmpty else {
            return false
        }
        if connected != false {
            connected = false
        }
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        let params = NWParameters(tls: nil, tcp: tcpOptions)
        Swift.print("Connecting with \(serverIP) : \(serverPort)")
        nwConnection = NWConnection(host: NWEndpoint.Host(serverIP), port: NWEndpoint.Port(serverPort)!, using: params)
        guard nwConnection != nil else {
            return false
        }
        nwConnection?.stateUpdateHandler = stateDidChange(to:)
        nwConnection?.start(queue: DispatchQueue.main)
        return true
    }

    // =============================================================================================================
    // Data sending related items
    // =============================================================================================================

    // ===============================================================================================================
    func send(data:Data) -> Bool {
        guard nwConnection != nil else {
            return false
        }
        nwConnection!.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                Swift.print("Send failed")
                self.connectionDidFail(error: error)
                return
            }
        }))
        return true
    }

    // =============================================================================================================
    // Reading related items
    // =============================================================================================================

    // ================================================================================================================
    func setupRead() -> Bool {
        self.idleTimer?.invalidate()
        self.idleTimer = nil
        self.incomingPacket = Data()
        self.scheduleTimer()
        return self.read(amount: 8)
    }

    // ================================================================================================================
    func read(amount:Int) -> Bool{
        guard nwConnection != nil else {
            return false
        }
    
        nwConnection!.receive(minimumIncompleteLength: amount, maximumLength: amount) { data, _, isComplete, error in
            if isComplete {
                Swift.print("Connection ended,  is completed!")
                self.connectionDidEnd()
                
            }
            else if let error = error {
                // Do something
                Swift.print("Connect.read had error")
                self.connectionDidFail(error: error)
            }
            else if let data = data, !data.isEmpty {
                if self.incomingPacket.isEmpty {
                    self.incomingPacket = data
                }
                else {
                    self.incomingPacket.append(data)
                }
                let delta = Int(self.incomingPacket.packetLength) - self.incomingPacket.count
                if delta > 0 {
                    DispatchQueue.main.async {
                        _ = self.read(amount: delta)
                    }
                    
                }
                else {
                    // We are complete!
                    self.idleTimer?.invalidate()
                    self.idleTimer = nil
                    self.processPacket(data:self.incomingPacket)
                    DispatchQueue.main.async {
                        _ = self.setupRead()
                    }

                    
                }
            }
        }
        return true
    }
 
}
