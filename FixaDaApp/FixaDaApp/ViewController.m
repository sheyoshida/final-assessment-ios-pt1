//
//  ViewController.m
//  FixaDaApp
//
//  Created by Michael Kavouras on 2/14/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FoursquareAPIManager.h"
#import "VenueObject.h"

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
MKMapViewDelegate
>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL foundPlaces;

@property (nonatomic) NSMutableArray *venues;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.mapView.delegate = self;
    
    self.venues = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager requestWhenInUseAuthorization];
}


# pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeepBoopCellIdentifier"];

    VenueObject *venue = self.venues[indexPath.row];
    NSString *name = venue.name; // this comes from the api call and object...
    cell.textLabel.text = name;
    
    return cell;
}

# pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.foundPlaces) {
        self.foundPlaces = YES;
        
        [self zoomToLocation:userLocation.location];
        [self fetchVenuesAtLocation:userLocation.location];
    }
}

- (void)zoomToLocation:(CLLocation *)location
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05f,0.05f);
    CLLocationCoordinate2D coordinate = location.coordinate;
    MKCoordinateRegion region = {coordinate, span};
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
    [self.mapView setRegion:regionThatFits animated:YES];
}

- (void)fetchVenuesAtLocation:(CLLocation *)location
{
        __weak typeof(self) weakSelf = self;
        [FoursquareAPIManager findSomething:@"music"
                                 atLocation:location
                                 completion:^(NSMutableArray *data){
                                     
                                     self.venues = data; // pull data with the block!
                                     
                                     weakSelf.venues = data;
                                     [weakSelf.tableView reloadData];
                                     [weakSelf showPins];
                                     
                                 }];
}

- (void)showPins
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (VenueObject *venue in self.venues) {
        double lat = venue.lat;
        double lng = venue.lng;
    
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(lat, lng);
        [self.mapView addAnnotation:point];
    }
}


@end
