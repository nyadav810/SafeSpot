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
    parkingInfo->streetName = malloc(sizeof(char) * streets.length -4);
    strncpy(parkingInfo->streetName, [streets UTF8String], streets.length -4);
    
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
    // or use substring to get certain parts
    
    // NSString *details =  s[32]; // more on the restrictions
    
    // setting restrictions days/hours
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

- (void)buildTree:(int)time withDay:(int)day
{
    @autoreleasepool {
        
        NSLog(@"RAWR i am a tree calling yo");
        
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
        
        NSInteger count = signs.count - 1; //might not need -1
        
        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        
        // maybe have an array of restrictions?
        
        int i = 0;
        for(NSArray *s in signs){
            i++; //?
            dataArray[i] = TBDataFromLine(s);
            float latitude = dataArray[i].x;
            float longitude = dataArray[i].y;
            //maybe have start/end hour/day as a int
            
            TBParkingInfo info = *(TBParkingInfo *)dataArray[i].data;
            
    
            
            Restrictions *rest = [[Restrictions alloc] init];
            rest.title =  [NSString stringWithFormat:@"%s", info.streetName];
            rest.comment = [NSString stringWithFormat:@"%s", info.restrictions];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
           
            CLLocationCoordinate2D coordinate = [location coordinate];
            rest.location = location;
            rest.coordinate = coordinate;

            // day compare first, if its okay check hour comparator
            // only run if not start and end hour are not null
            //[self dayComparator:info.startDay end:info.endDay today:day] [self hourComparator:info.startHour hour:info.endHour ct:time]
            
            if(day == 1){ //
                info.parkType; //place if its restricted/paid
                
            }
            
            //THIRD TEST, PRZ/? under category
            // cant if PNP, PNS
            
            if(i < 30 ){//&& ([self dayComparator:info.startDay end:info.endDay today:day] ||[self hourComparator:info.startHour hour:info.endHour ct:time])){
                
                [self.mapView addAnnotation:rest]; //shouldnt be here..? or maybe it should
            
            }
            
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
        NSLog(@"%d", currentDay);
        return true;

    }

    return false;
}


// doesnt cluster, but adds signs in this rect to map
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
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

            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) { // crashes
                //need to pass in root
                totalX += data.x;
                totalY += data.y;
                
                // count++;
                
                TBParkingInfo info = *(TBParkingInfo *)data.data;
                /*
                [names addObject:[NSString stringWithFormat:@"%s", hotelInfo.streetName]];
                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", hotelInfo.restrictions]];
                */
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(data.x, data.y);
                Restrictions *rest = [[Restrictions alloc] init];
                rest.coordinate = coordinate;
                rest.title =  [NSString stringWithFormat:@"%s", info.streetName];
                rest.comment = [NSString stringWithFormat:@"%s", info.restrictions];
                //NSLog(@"%@",totalX);
                [clusteredAnnotations addObject:rest];
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