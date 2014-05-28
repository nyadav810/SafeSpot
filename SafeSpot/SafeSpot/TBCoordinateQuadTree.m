//
// TBCoordinateQuadTree.m
// TBAnnotationClustering
//
// Created by Theodore Calmes on 9/27/13.
// Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"

#import "Restrictions.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct TBParkingInfo {
    char* streetName;
    char* restrictions;
    char* parkType; // will tell if paid parking/RPZ/what the restriction is
    
    int startHour;
    int endHour;
    int startDay;
    int endDay;
    // maybe add category Char
    
} TBParkingInfo;


// pass in array
TBQuadTreeNodeData TBDataFromLine(NSArray *s)
{

    float latitude = (float) [s[35] floatValue];
    float longitude = (float) [s[36]floatValue];
    
    TBParkingInfo* parkingInfo = malloc(sizeof(TBParkingInfo));
    
    NSString *streets =  s[21]; // maybe change length to -4 ?
    parkingInfo->streetName = malloc(sizeof(char) * streets.length ); //
    strncpy(parkingInfo->streetName, [streets UTF8String], streets.length );
    
    NSString *parkingStreet = s[20];
    NSString *pt = s[19]; // RPZ, blah blah type name

    parkingInfo->parkType = malloc(sizeof(char) * pt.length + 1);
    strncpy(parkingInfo->parkType, [pt UTF8String], pt.length + 1);
    
    parkingInfo->restrictions = malloc(sizeof(char) * parkingStreet.length + 1);
    strncpy(parkingInfo->restrictions, [parkingStreet UTF8String], parkingStreet.length + 1);


    // 79515 sets it to 1-1 ._.
    // ~700, might need to find a hotfix/hard code those points in?
    

    //15TH AVE S 0320 BLOCK W SIDE ( 247) 247 FT S/O S HANFORD ST (R7-NP )
    // http://stackoverflow.com/questions/6825834/objective-c-how-to-extract-part-of-a-string-e-g-start-with

    // NSString *details =  s[32]; // more on the restrictions

    parkingInfo->startHour = -100;
    parkingInfo->endHour = -100;
    parkingInfo->startDay = -100;
    parkingInfo->endDay = -100;
    
    if( s[33] != [NSNull null]){
        parkingInfo->startHour =  (int) [s[33] integerValue];
        //NSLog(@"%d",startHour);
    }
    
    if( s[34] != [NSNull null]){
        parkingInfo->endHour =  (int) [s[34] integerValue];
        //NSLog(@"%d",endHour);
    }
    
    if( s[31] != [NSNull null]){
        parkingInfo->startDay =  (int) [s[31] integerValue];
    }
    
    
    if( s[32] != [NSNull null]){
        parkingInfo->endDay =  (int) [s[32] integerValue];
    }

    // maybe make Restriction have Restrictions( or some other name) so one holds the streets restrictions
    // Restrictions have startDay/Hour and endDay/Hour and custom Text
    
    return TBQuadTreeNodeDataMake(latitude, longitude, parkingInfo);
}



TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));
    
    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);
    
    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;
            
        default:
            return 88;
    }
}

@implementation TBCoordinateQuadTree

- (void)buildTree
{
    @autoreleasepool {

        NSError *error;
        // JSON Datasoure: http://data.seattle.gov/resource/it8u-sznv.json
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rows" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        //NSArray *signs = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary *rawSigns = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!rawSigns) {
            NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
        }
        
        NSArray *signs = [rawSigns objectForKey:@"data"];
        
        int count = (int) signs.count - 1; //might not need -1
        
        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        
        int i = 0;
        for(NSArray *s in signs){
            i++; //?
            dataArray[i] = TBDataFromLine(s);

            // day compare first, if its okay check hour comparator
            // only run if not start and end hour are not null
            //[self dayComparator:info.startDay end:info.endDay today:day] [self hourComparator:info.startHour hour:info.endHour ct:time]
          //&& ([self dayComparator:info.startDay end:info.endDay today:day] ||[self hourComparator:info.startHour hour:info.endHour ct:time])){
            
        }
        
        NSLog(@"%d",i);
        
        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
        // not sure what the bounding box does :(
        _root = TBQuadTreeBuildWithData(dataArray, count, world, 4);
    }
}

- (Boolean)hourComparator:(NSUInteger)start hour:(NSUInteger)endHour ct:(NSUInteger)current{
    
    //have to change start/end if its -100 aka null
    if(current == -100){
        return false;
    }
    
    if(endHour < current){
        return true;
    } else if(current >= start){ // its its after restriction
        return true;
    }

    return false;
}

// Possibly debug current hour
// http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c



// pass in todays date
- (Boolean) dayComparator:(NSUInteger)startDay end:(NSUInteger)endDay today:(NSUInteger)currentDay{ // if start date exists compare it
    
    if(currentDay == -100){
        return false;
    }
    
    //have to change start/end if its -100 aka null
    if(currentDay < startDay && currentDay > endDay ){
       
        return true;

    }

    return false;
}


// doesnt cluster, but adds signs in this rect to map
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale c:(int)time withDay:(int)day b:(bool)clust
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            
            __block Restrictions *last = NULL;
            
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) { // crashes
                //need to pass in root
                totalX += data.x;
                totalY += data.y;
                
                count++;
                
                TBParkingInfo info = *(TBParkingInfo *)data.data;
                // http://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps
                
                Restrictions *rest = [[Restrictions alloc] init];
                
                // rest.title =  [NSString stringWithFormat:@"%s", info.parkType];
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(data.x, data.y);
                rest.coordinate = coordinate;
                
                rest.title =  [NSString stringWithFormat:@"%s", info.streetName]; // street signs might be moving around
                rest.comment = [NSString stringWithFormat:@"%s", info.restrictions];
                NSString *parkingType = [NSString stringWithFormat:@"%s",info.parkType];
                
                // http://stackoverflow.com/questions/13522198/setting-map-pin-colour-dynamically-for-ios
                if([parkingType isEqual: @"PPP"] || [parkingType  isEqual: @"PTIML"] ){ //
                    
                    rest.pinColor = MKPinAnnotationColorGreen ;//place if its restricted/paid
                    // PPP, PTIML, all paid
                    // P1530, P1H
                    // PDIS is disabled
                    // PRZ
                    // NSLog(@"%@",rest.pinColor);
                    // NSLog(@"Green paid ppp");
                }else if([parkingType  isEqual: @"P1530"] || [parkingType  isEqual: @"P1H"] ){
                    rest.pinColor = MKPinAnnotationColorPurple;
                    // NSLog(@"purple p15/timed? need to relook what this restriction is lol");
                }else if([parkingType  isEqual: @"PRZ"]){
                    rest.pinColor = MKPinAnnotationColorPurple;
                    // NSLog(@"purple RPZZZ one");
                    
                }else if([parkingType  isEqual: @"PDIS"]){
                    rest.pinColor = MKPinAnnotationColorPurple;
                    // NSLog(@"purple PDIS  ");
                    
                } //
                // need other icons, so probably add another property
                //THIRD TEST, PRZ/? under category
                // cant if PNP, PNS

            

                // split text
                NSArray * split = [rest.title componentsSeparatedByString:@" "];
                int counterForStreet = 0;

                // change end bounds later maybe
                for (int i = (int)(split.count - 3); i > 4; i--) {
                    if([split[i] length] > 1){
                        NSString *code = [split[i] substringFromIndex: [split[i] length] - 2];
                        // CAN use the part before/ to decide street side. COULD be hard cause of NW/SW
                        if ([code isEqualToString:@"/O"] ) { // might not be the best
                            
                            counterForStreet = i;
                            //maybe break/leave FOR loop
                            break;
                        }
                    }
                    // Things before / is side of street (for later)
                }
                rest.title = [NSString stringWithFormat:@"%@ %@ & %@ %@", split[0], split[1], split[counterForStreet+1], split[counterForStreet+2]];
                
                    //rest.title = [NSString stringWithFormat:@"%@ %@ & %@ %@ %@", split[0], split[1], split[counterForStreet+1], split[counterForStreet+2], parkingType];

                
                // if last != null &&, or set boolean to show last != null
                //[rest.title isEqualToString:last.title]; // Find way to add Restriction to restriction
                // might not want count,
                
                if(clust){
                    //maybe use last object ?
                    if(last != NULL && ![rest.title isEqualToString:last.title]){
                        //CLLocationCoor dinate2D coordinate = CLLocationCoordinate2DMake(data.x, data.y);
                        //rest.coordinate = coordinate;
                        [clusteredAnnotations addObject:rest];
                        // [clusteredAnnotations addObject:rest];
                    }else { // Maybe use # of signs for icon clustering?
                        //problem with else, not clustering x.x
                        
                        NSLog(@"%@",rest.title);
                        NSLog(@"%@",last.title);
                        // problem, streets are flippin floppin, aka
                        /*
                         2014-05-27 13:50:27.726 SafeSpot[65737:3c03] MINOR AVE & MARION ST
                         2014-05-27 13:50:27.726 SafeSpot[65737:3c03] MARION ST & BOREN AVE
                         2014-05-27 13:50:27.727 SafeSpot[65737:3c03] MINOR AVE & MARION ST
                         2014-05-27 13:50:27.727 SafeSpot[65737:3c03] MARION ST & BOREN AVE
                         2014-05-27 13:50:27.727 SafeSpot[65737:3c03] MARION ST & BOREN AVE
                         */
                        [last.clusterRestriction addObject:rest];
                        // maybe have NINJA way of holding onto 1st restriction(parent) reference
                        
                    }
                        
                }else{// bool false
                    [clusteredAnnotations addObject:rest];

                }
                
                // Add setting to ONLY show where you cant park?
                //if ( !([self dayComparator:info.startDay end:info.endDay today:day]) || !([self hourComparator:info.startHour hour:info.endHour ct:time]) ){
                      // NSLog(@"%s",info.parkType);
                    // NSLog(@"%@",last.title);
                
                    last = rest;
                
                    // Need some type of collision detection/combo
                
                });
            
                //TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                //annotation.title = [names lastObject];
                //annotation.subtitle = [phoneNumbers lastObject];
                //[clusteredAnnotations addObject:annotation];
                
            }
    }
    
    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end