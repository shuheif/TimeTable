//
//  CustomColor.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/28.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    class func hex (hexStr : NSString) -> UIColor {
        
        var hexStr = hexStr
        let alpha: CGFloat = 1.00
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r, green:g, blue:b, alpha:alpha)
        } else {
            print("Invalid HEX string.")
            return UIColor.white
        }
    }
    
    
    //original
    class func Sakura() ->  UIColor {return  UIColor(red: 0.910, green: 0.824, blue: 0.949, alpha: 1.00)}
    class func SkyBlue() ->  UIColor {return  UIColor(red: 0.286, green: 0.396, blue: 0.596, alpha: 1.00)}
    class func WaterBlue() -> UIColor   {return  UIColor(red: 0.443, green: 0.576, blue: 0.871, alpha: 1.00)}
    
    //Labelcolor
    class func labelBluePurple() -> UIColor {return UIColor(red: 0.227, green: 0.341, blue: 0.600, alpha: 1.00)}
    class func labelPurple() -> UIColor {return UIColor(red: 0.561, green: 0.388, blue: 0.651, alpha: 1.00)}
    class func labelPink() -> UIColor {return UIColor(red: 0.651, green: 0.388, blue: 0.612, alpha: 1.00)}
    class func labelRed() -> UIColor {return UIColor(red: 0.651, green: 0.388, blue: 0.482, alpha: 1.00)}
    class func labelOrange() -> UIColor {return UIColor(red: 0.800, green: 0.494, blue: 0.000, alpha: 1.00)}//#CC7E00
    class func labelYellow() -> UIColor {return UIColor(red: 0.651, green: 0.561, blue: 0.388, alpha: 1.00)}
    class func labelYellowGreen() -> UIColor {return UIColor(red: 0.612, green: 0.651, blue: 0.388, alpha: 1.00)}
    class func labelBrightYG() -> UIColor {return UIColor(red: 0.482, green: 0.651, blue: 0.388, alpha: 1.00)}
    class func labelGreen() -> UIColor {return UIColor(red: 0.388, green: 0.651, blue: 0.427, alpha: 1.00)}
    class func labelEme() -> UIColor {return UIColor(red: 0.388, green: 0.651, blue: 0.561, alpha: 1.00)}
    class func labelWater() -> UIColor {return UIColor(red: 0.388, green: 0.612, blue: 0.651, alpha: 1.00)}
    class func labelBlack() -> UIColor {return UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.00)}//#999999
    
    //sideLineColor
    class func sideBlue() -> UIColor {return UIColor(red: 0.318, green: 0.475, blue: 0.839, alpha: 1.00)}
    class func sidePurple() -> UIColor {return UIColor(red: 0.682, green: 0.318, blue: 0.839, alpha: 1.00)}
    class func sidePink() -> UIColor {return UIColor(red: 0.839, green: 0.318, blue: 0.737, alpha: 1.00)}
    class func sideRed() -> UIColor {return UIColor(red: 0.839, green: 0.318, blue: 0.475, alpha: 1.00)}
    class func sideOrange() -> UIColor {return UIColor(red: 0.894, green: 0.561, blue: 0.000, alpha: 1.00)}//#e48e00
    class func sideYellow() -> UIColor {return UIColor(red: 0.839, green: 0.682, blue: 0.318, alpha: 1.00)}
    class func sideYellowGreen() -> UIColor {return UIColor(red: 0.737, green: 0.839, blue: 0.318, alpha: 1.00)}
    class func sideBrightYG() -> UIColor {return UIColor(red: 0.475, green: 0.839, blue: 0.318, alpha: 1.00)}
    class func sideGreen() -> UIColor {return UIColor(red: 0.318, green: 0.839, blue: 0.424, alpha: 1.00)}
    class func sideEme() -> UIColor {return UIColor(red: 0.318, green: 0.839, blue: 0.682, alpha: 1.00)}
    class func sideWater() -> UIColor {return UIColor(red: 0.318, green: 0.737, blue: 0.839, alpha: 1.00)}
    class func sideLineBlack() -> UIColor {return UIColor(red: 0.702, green: 0.702, blue: 0.702, alpha: 1.00)}//#b3b3b3
    
    //backColor
    class func cellBackBlue() -> UIColor {return UIColor(red: 0.835, green: 0.878, blue: 0.949, alpha: 1.00)}
    class func cellBackPurple() -> UIColor {return UIColor(red: 0.910, green: 0.835, blue: 0.949, alpha: 1.00)}
    class func cellBackPink() -> UIColor {return UIColor(red: 0.949, green: 0.835, blue: 0.933, alpha: 1.00)}
    class func cellBackRed() -> UIColor {return UIColor(red: 0.949, green: 0.835, blue: 0.878, alpha: 1.00)}
    class func cellBackOrange() -> UIColor {return UIColor(red: 1.000, green: 0.922, blue: 0.800, alpha: 1.00)}//#FFEbcc
    class func cellBackYellow() -> UIColor {return UIColor(red: 0.996, green: 0.988, blue: 0.859, alpha: 1.00)}
    class func cellBackYellowGreen() -> UIColor {return UIColor(red: 0.933, green: 0.949, blue: 0.835, alpha: 1.00)}
    class func cellBackBrightYG() -> UIColor {return UIColor(red: 0.878, green: 0.949, blue: 0.835, alpha: 1.00)}
    class func cellBackGreen() -> UIColor {return UIColor(red: 0.835, green: 0.949, blue: 0.851, alpha: 1.00)}
    class func cellBackEme() -> UIColor {return UIColor(red: 0.835, green: 0.949, blue: 0.910, alpha: 1.00)}
    class func cellBackWater() -> UIColor {return UIColor(red: 0.835, green: 0.933, blue: 0.949, alpha: 1.00)}
    class func cellBackBlack() -> UIColor {return UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.00)}//#e6e6e6
    
    
    //VeryPaleTone
    
    class func c10m20() -> UIColor {
        return UIColor.hex(hexStr: "E7D5E8")
    }
    class func m20() -> UIColor {
        return UIColor.hex(hexStr: "FADCE9")
    }
    class func m20y10() -> UIColor {
        return UIColor.hex(hexStr: "FADBDA")
    }
    class func m20y20() -> UIColor {
        return UIColor.hex(hexStr: "FBDAC8")
    }
    class func m10y20() -> UIColor {
        return UIColor.hex(hexStr: "FEECD2")
    }
    class func y20() -> UIColor {
        return UIColor.hex(hexStr: "FFFCDB")
    }
    class func c10y20() -> UIColor {
        return UIColor.hex(hexStr: "ECF4D9")
    }
    class func c20y20() -> UIColor {
        return UIColor.hex(hexStr: "D5EAD8")
    }
    class func c20y10() -> UIColor {
        return UIColor.hex(hexStr: "D4ECEA")
    }
    class func c20() -> UIColor {
        return UIColor.hex(hexStr: "D3EDFB")
    }
    class func c20m10() -> UIColor {
        return UIColor.hex(hexStr: "D3DEF1")
    }
    class func c20m20() -> UIColor {
        return UIColor.hex(hexStr: "D2CCE6")
    }
    
    
    //BrightTone
    
    class func c40m80() -> UIColor {
        return UIColor.hex(hexStr: "A64A97")
    }
    class func m80() -> UIColor {
        return UIColor.hex(hexStr: "E85298")
    }
    class func m80y40() -> UIColor {
        return UIColor.hex(hexStr: "E9546B")
    }
    class func m80y80() -> UIColor {
        return UIColor.hex(hexStr: "EA5532")
    }
    class func m40y80() -> UIColor {
        return UIColor.hex(hexStr: "F6AD3C")
    }
    class func y80() -> UIColor {
        return UIColor.hex(hexStr: "FFF33F")
    }
    class func c40y80() -> UIColor {
        return UIColor.hex(hexStr: "AACF52")
    }
    class func c80y80() -> UIColor {
        return UIColor.hex(hexStr: "00A95F")
    }
    class func c80y40() -> UIColor {
        return UIColor.hex(hexStr: "00ADA9")
    }
    class func c80() -> UIColor {
        return UIColor.hex(hexStr: "00AFEC")
    }
    class func c80m40() -> UIColor {
        return UIColor.hex(hexStr: "187FC4")
    }
    class func c80m80() -> UIColor {
        return UIColor.hex(hexStr: "4D4398")
    }
    
    
    //StrongTone
    
    class func c50m100k10() -> UIColor {
        return UIColor.hex(hexStr: "8A017C")
    }
    class func m100k10() -> UIColor {
        return UIColor.hex(hexStr: "D60077")
    }
    class func m100y50k10() -> UIColor {
        return UIColor.hex(hexStr: "D7004A")
    }
    class func m100y100k10() -> UIColor {
        return UIColor.hex(hexStr: "D7000F")
    }
    class func m50y100k10() -> UIColor {
        return UIColor.hex(hexStr: "E48E00")
    }
    class func y100k10() -> UIColor {
        return UIColor.hex(hexStr: "F3E100")
    }
    class func c50y100k10() -> UIColor {
        return UIColor.hex(hexStr: "86B81B")
    }
    class func c100y100k10() -> UIColor {
        return UIColor.hex(hexStr: "009140")
    }
    class func c100y50k10() -> UIColor {
        return UIColor.hex(hexStr: "00958D")
    }
    class func c100k10() -> UIColor {
        return UIColor.hex(hexStr: "0097DB")
    }
    class func c100m50k10() -> UIColor {
        return UIColor.hex(hexStr: "0062AC")
    }
    class func c100m100k10() -> UIColor {
        return UIColor.hex(hexStr: "1B1C80")
    }
    
    
    //Cell用色選択関数
    class func cellLineColor (color: Int) -> UIColor {
        
        switch color {
        case 0: return UIColor.c40m80()
        case 1: return UIColor.m80()
        case 2: return UIColor.m80y40()
        case 3: return UIColor.m80y80()
        case 4: return UIColor.m40y80()
        case 5: return UIColor.y80()
        case 6: return UIColor.c40y80()
        case 7: return UIColor.c80y80()
        case 8: return UIColor.c80y40()
        case 9: return UIColor.c80()
        case 10: return UIColor.c80m40()
        case 11: return UIColor.c80m80()
        default: return UIColor.hex(hexStr: "898989")
        }
    }
    
    
    class func cellLabelColor (color: Int) -> UIColor {
        
        switch color  {
        case 0: return UIColor.c50m100k10()
        case 1: return UIColor.m100k10()
        case 2: return UIColor.m100y50k10()
        case 3: return UIColor.m100y100k10()
        case 4: return UIColor.hex(hexStr: "D28300")//DeepTone
        case 5: return UIColor.hex(hexStr: "B7AA00")//DarkTone
        case 6: return UIColor.c50y100k10()
        case 7: return UIColor.c100y100k10()
        case 8: return UIColor.c100y50k10()
        case 9: return UIColor.c100k10()
        case 10: return UIColor.c100m50k10()
        case 11: return UIColor.c100m100k10()
        default: return UIColor.hex(hexStr: "727171")
        }
    }
    
    class func cellBackColor (color: Int) -> UIColor {
        
        switch color  {
        case 0: return UIColor.c10m20()
        case 1: return UIColor.m20()
        case 2: return UIColor.m20y10()
        case 3: return UIColor.m20y20()
        case 4: return UIColor.m10y20()
        case 5: return UIColor.y20()
        case 6: return UIColor.c10y20()
        case 7: return UIColor.c20y20()
        case 8: return UIColor.c20y10()
        case 9: return UIColor.c20()
        case 10: return UIColor.c20m10()
        case 11: return UIColor.c20m20()
        default: return UIColor.hex(hexStr: "DCDDDD")
        }
    }
    
    
    class func themeColor (num: Int) -> UIColor {
    
        switch num {
        case 0: return UIColor.jadeColor()
        case 1: return UIColor.peterRiverColor()
        case 2: return UIColor.SkyBlue()
        case 3: return UIColor.amethystColor()
        case 4: return UIColor.Sakura()
        case 5: return UIColor.alizarinColor()
        case 6: return UIColor.orangeFlatColor()
        case 7: return UIColor.sunflowerColor()
        case 8: return UIColor.asbestosColor()
        default:return UIColor.nephritisColor()
        }
    }
}
