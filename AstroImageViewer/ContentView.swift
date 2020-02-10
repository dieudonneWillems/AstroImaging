//
//  ContentView.swift
//  AstroImageViewer
//
//  Created by Don Willems on 08/02/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import SwiftUI
import AppKit
import AstroImaging

class TempClass {
    
}

extension NSImage.Name {
     static let stars1 = NSImage.Name("stars1")
     static let trees = NSImage.Name("trees")
}

struct ContentView: View {
    
    let appBundle = Bundle(for: TempClass.self)
    
    var body: some View {
        let nsimage = appBundle.image(forResource: .trees)
        var image = nsimage
        do {
        let asimage = try ASImage(withWidth: Int(nsimage!.size.width), andHeight: Int(nsimage!.size.height))
            let ns2image = NSImage(cgImage:     asimage.cgImage!, size: NSZeroSize)
            image = ns2image
        } catch {
            image = nsimage
            print(error)
        }
        let imageview = Image(nsImage: image!).frame(width: 1000.0, height: 800.0)
        return imageview
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
