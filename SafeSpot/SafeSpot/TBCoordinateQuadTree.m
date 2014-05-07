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

typedef struct TBHotelInfo {
    char* hotelName;
    char* hotelPhoneNumber;
} TBHotelInfo;


// pass in array
TBQuadTreeNodeData TBDataFromLine(NSArray *s)
{

    float latitude = (float) [s[35] floatValue];
    float longitude = (float) [s[36]floatValue];
    
    TBHotelInfo* hotelInfo = malloc(sizeof(TBHotelInfo));
    
    NSString *hotelName =  s[21];;
    
    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
    
    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);
    
    NSString *hotelPhoneNumber = s[20];
    
    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);
    
    

    
    // 79515 sets it to 1-1 ._.
    // ~700, might need to find a hotfix/hard code those points in?
    
    NSString *title =  s[21]; // Street Names
    //15TH AVE S 0320 BLOCK W SIDE ( 247) 247 FT S/O S HANFORD ST (R7-NP )
    // http://stackoverflow.com/questions/6825834/objective-c-how-to-extract-part-of-a-string-e-g-start-with
    // or use substring to get certain parts
    
    
    NSString *comment =  s[20]; // Restrictions
    
    NSString *details =  s[32]; // more on the restrictions
    
    int startHour = -100;
    int endHour = -100;
    int startDay = -100;
    int endDay = -100;
    
    if( s[33] != [NSNull null]){
        startHour =  (int) [s[33] integerValue];
        //NSLog(@"%d",startHour);
    }else{
        // ~ 200-300 unlabeled but HAS restrictions id startHour = s[33]; //-10; //?
        // NSLog(@"%@",startHour);
    }
    
    if( s[34] != [NSNull null]){
        endHour =  (int) [s[34] integerValue];
        //NSLog(@"%d",endHour);
        
    }else{
        
    }
    
    //maybe make a boolean to verify non null?
    if( s[31] != [NSNull null]){
        startDay =  (int) [s[31] integerValue];
    }else{
        
    }
    
    if( s[32] != [NSNull null]){
        endDay =  (int) [s[32] integerValue];
        // NSLog(@"%d",endDay);
    }else{
        
    }
    // Only run if start and end are not null
    // [self dayComparator:startDay end:endDay today:weekday];
    
    
    // maybe make Restriction have Restrictions( or some other name) so one holds the streets restrictions
    // Restrictions have startDay/Hour and endDay/Hour and custom Text
    
    
    
    
    return TBQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
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

- (void)buildTree:(NSArray *)signs withTime:(int)time withDay:(int)day
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
        int i = 0;
        for(NSArray *s in signs){
            i++; //?
            dataArray[i] = TBDataFromLine(s);
            float latitude = dataArray[i].x;
            float longitude = dataArray[i].y;
            
            
            //NSLog(@"%@",dataArray[i].data);
            
            Restrictions *rest = [[Restrictions alloc] init];
            rest.title = @"i am a title idk";//String) dataArray[i].data;
            rest.comment = @"";
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
           
            CLLocationCoordinate2D coordinate = [location coordinate];
            rest.location = location;
            rest.coordinate = coordinate;
            
            
            // [self mapView addAnnotation
            
            // day compare first, if its okay check hour comparator
            // only run if not start and end hour are not null
            
            //NSLog(@"%f,%f",latitude,longitude);
            if(i < 300){
                [self.mapView addAnnotation:rest];
                NSLog(@"%f",latitude);
            
            }
            
        }
        
        NSLog(@"%d",i);
        
        
        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
        // not sure what the bounding box does :(
        
        _root = TBQuadTreeBuildWithData(dataArray, count, world, 4);
    }
}

- (Boolean)hourComparator:(NSUInteger)start hour:(NSUInteger)endHour ct:(NSUInteger)current{ //add param for current
    
    
    //have to change start/end if its -100 aka null
    if(current == -100){
        return false;
    }
    
    if(endHour < current){ //its after the restriction, maybe && statement for start..?
        //cant park
        // NSLog(@"test can park yay!");
        //return false;
        
        return true;
    } else if(current >= start){ // its its after restriction
        //can park
        //NSLog(@"test hours cant park finish");
        
        // NSLog(@"%d,%d",start,endHour);
        
        return true;
    }
    
    return false; //will reach?
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
        // true?
        //
        
        NSLog(@"%d", currentDay);
        return true;
        
    }
    //get todays date
    
    return false;
}





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
            __block int count = 0;
            
            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
                
                TBHotelInfo hotelInfo = *(TBHotelInfo *)data.data;
                [names addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelName]];
                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelPhoneNumber]];
            });
            
            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                
                //TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                //annotation.title = [names lastObject];
                //annotation.subtitle = [phoneNumbers lastObject];
                //[clusteredAnnotations addObject:annotation];
                
            }
            
            if (count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                //TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                //[clusteredAnnotations addObject:annotation];
            }
        }
    }
    
    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end