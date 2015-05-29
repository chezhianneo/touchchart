//
//  WalmartLandingPageViewController.m
//  Walmart
//
//  Created by Rizwan on 8/23/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import "WalmartLandingPageViewController.h"
#import "SettingsViewController.h"
/**************************************************************************************/
@interface WalmartLandingPageViewController ()
-(void)customizeHeaderView;
-(void)addFooterView;
-(void)customColorsForLabels;
-(void)addHeaderView;
@end
/**************************************************************************************/
@implementation WalmartLandingPageViewController
@synthesize fileURL;
@synthesize buCumSalesDict;
/**************************************************************************************/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/**************************************************************************************/
#pragma mark- ViewLifecycle
/**************************************************************************************/

-(void)viewWillAppear:(BOOL)animated
{
    singletonTableSelection.selectedBUValue = @"";
    singletonTableSelection.selectedSBUValue = @"";
    singletonTableSelection.selectedITMValue = @"";
    singletonTableSelection.selectedDeptValue = @"";
    
    [headerView removeFromSuperview];
    [self addHeaderView];

    [headerView customButtonTapped:@"zero"];
    [[headerView buTable]reloadData];
    [[headerView sbuTable]reloadData];
    [[headerView itmTable]reloadData];
    headerView.sbuView.hidden = YES;
    headerView.itemView.hidden = YES;
    headerView.sbuTable.hidden = YES;
    headerView.itmTable.hidden = YES;
    headerView.deptView.hidden = YES;
    headerView.deptTable.hidden = YES;
    headerView.segmentedControl.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    snap = YES;
    
    singletonTableSelection = [SelectionHeaderSingleton sharedManager];

    
    [self.barChartImageView setUserInteractionEnabled:YES];
    [self addFooterView];
    
    UITapGestureRecognizer *tappedWalmart = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getTheEventBarChartImageView:)];
    tappedWalmart.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tappedSams = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getTheEventBarChartImageView:)];
    tappedSams.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tappedCom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getTheEventBarChartImageView:)];
    tappedCom.numberOfTapsRequired = 1;
    [self.walmartImageView setUserInteractionEnabled:YES];
    [self.salesClubImageView setUserInteractionEnabled:YES];
    [self.dotComImageView setUserInteractionEnabled:YES];
    
    
    [self.walmartImageView addGestureRecognizer:tappedWalmart];
    [self.salesClubImageView addGestureRecognizer:tappedSams];
    [self.dotComImageView addGestureRecognizer:tappedCom];
    
    [[[self.view subviews]objectAtIndex:0] setExclusiveTouch:YES];
    [self setExclusiveTouchForButtons:[[self.view subviews]objectAtIndex:0]];
    database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Walmart.sqlite"]];
    EGODatabaseResult* result = [database executeQueryWithParameters:@"SELECT SUM(CUM_TOTAL_TY) AS TOTAL_SALES FROM TBL_BU_SBU_SALES_TYLY_HOURLY WHERE SALES_TIME = '2012-11-23 21:00:00' AND BU IN ('Walmart','Sams Club','.Com')", nil];
    
    NSMutableString *str = [[NSMutableString alloc]init];
    [str appendString:@"$"];
    for(EGODatabaseRow* row in result) {
        [str appendFormat:@"%@",[row stringForColumn:@"TOTAL_SALES"]];
    }
    [str appendString:@"M"];
    [self.totalSalesCount setText:str];
    [self.pieChartView setUserInteractionEnabled:YES];
    TBMChartView *chartView = [self _chartView];
    chartView.delegate=self;
	[self.pieChartView addSubview:chartView];
    NSArray *slices = [self _demoSlices];
	chartView.slices = slices;
    
    
    EGODatabaseResult* result1 = [database executeQueryWithParameters:@"SELECT BU, SUM(CUM_TOTAL_TY) AS TOTAL_SALES FROM TBL_BU_SBU_SALES_TYLY_HOURLY WHERE SALES_TIME = '2012-11-23 21:00:00' AND BU IN('Sams Club', 'Walmart' , '.Com') GROUP BY BU", nil];
    
    NSMutableArray *array=[[ NSMutableArray alloc]init];
     NSMutableArray *arrayKey=[[ NSMutableArray alloc]init];
    for(EGODatabaseRow *row in result1)
    {
        [array addObject:[row stringForColumn:@"TOTAL_SALES"]];
        [arrayKey addObject:[row stringForColumn:@"BU"]];
    }
    buCumSalesDict = [[NSDictionary alloc]initWithObjects:array forKeys:arrayKey];
    
    NSMutableString *strWalmart = [[NSMutableString alloc]init];
    [strWalmart appendString:@"$"];
    [strWalmart appendString:[NSString stringWithFormat:@"%.02f",[[array objectAtIndex:2] floatValue]]];
    
    [strWalmart appendString:@"M"];
    [self.totalEventSaleWalmart setText:strWalmart];
    
    NSMutableString *strSamsClub = [[NSMutableString alloc]init];
    [strSamsClub appendString:@"$"];
    [strSamsClub appendString:[NSString stringWithFormat:@"%.02f",[[array objectAtIndex:1] floatValue]]];
    [strSamsClub appendString:@"M"];
    [self.totalEventSaleSamsClub setText:strSamsClub];
    
    
    NSMutableString *strCom = [[NSMutableString alloc]init];
    [strCom appendString:@"$"];
    [strCom appendString:[NSString stringWithFormat:@"%.02f",[[array objectAtIndex:0] floatValue]]];
    [strCom appendString:@"M"];
    [self.totalEventSaleDotCom setText:strCom];
    
    
   
    [self customColorsForLabels];
    [self customizeHeaderView];
    [self loadData];
    [self setupBarChart];
    [self setUpLineChart];
    


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/**************************************************************************************/
#pragma mark- Custom Methods
/**************************************************************************************/
-(void)customizeHeaderView{
    //Customize the Navigation Bar Title
    UILabel *titleText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    titleText.backgroundColor= [UIColor clearColor];
    titleText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
    titleText.textColor = UIColorFromRGB(0x333333);
    titleText.text = @"Walmart Annual Event";
    [self.navigationItem setTitleView:titleText];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 46;
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_normal.png"]];
    UIBarButtonItem *walmartLogo = [[UIBarButtonItem alloc]
                                    initWithCustomView:imgView];
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer, walmartLogo, nil];
    
    UIImageView *tcsImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tcslogo.png"]];
    UIBarButtonItem *tcsImage = [[UIBarButtonItem alloc]
                                    initWithCustomView:tcsImgView];
    UIImageView *sepImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"seperatorheader.png"]];
    UIBarButtonItem *sepImg = [[UIBarButtonItem alloc]
                                 initWithCustomView:sepImgView];
    UIBarButtonItem *btwGap = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    btwGap.width = 48;
    UILabel *powerText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 112, 25)];
    powerText.backgroundColor= [UIColor clearColor];
    powerText.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    powerText.textColor = UIColorFromRGB(0x333333);
    powerText.text = @"POC powered by:";
    UIBarButtonItem *powerTextLbl = [[UIBarButtonItem alloc]
                                 initWithCustomView:powerText];

    UIImage *settingsImage = [UIImage imageNamed:@"settingicon.png"];
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsBtn setImage:settingsImage forState:UIControlStateNormal];
    [settingsBtn setFrame:CGRectMake(0, 0, settingsImage.size.width, settingsImage.size.height)];
    [settingsBtn addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //Initializing the BarbuttonItem with Custom Button
    UIBarButtonItem *setBtn = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:setBtn,btwGap,sepImg,tcsImage,powerTextLbl, nil];

    
    
}

-(void)customizeHeaderViewScribbling{
    //Customize the Navigation Bar Title
    UILabel *titleText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 45, 25)];
    titleText.backgroundColor= [UIColor clearColor];
    titleText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
    titleText.textColor = UIColorFromRGB(0x333333);
    titleText.text = @"Walmart Annual Event";
    [self.navigationItem setTitleView:titleText];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 46;
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_normal.png"]];
    UIBarButtonItem *walmartLogo = [[UIBarButtonItem alloc]
                                    initWithCustomView:imgView];
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacer, walmartLogo, nil];
    
    UIImageView *tcsImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tcslogo.png"]];
    UIBarButtonItem *tcsImage = [[UIBarButtonItem alloc]
                                 initWithCustomView:tcsImgView];
    UIImageView *sepImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"seperatorheader.png"]];
    UIBarButtonItem *sepImg = [[UIBarButtonItem alloc]
                               initWithCustomView:sepImgView];
    UIBarButtonItem *btwGap = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil action:nil];
    btwGap.width = 48;
    UILabel *powerText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 112, 25)];
    powerText.backgroundColor= [UIColor clearColor];
    powerText.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    powerText.textColor = UIColorFromRGB(0x333333);
    powerText.text = @"POC powered by:";
    UIBarButtonItem *powerTextLbl = [[UIBarButtonItem alloc]
                                     initWithCustomView:powerText];
    
    UIImage *closeImage = [UIImage imageNamed:@"closeblue.png"];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeBtn addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //Initializing the BarbuttonItem with Custom Button
    UIBarButtonItem *closeNavBtn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:closeNavBtn,btwGap,sepImg,tcsImage,powerTextLbl, nil];
    
    
    
}

-(void)addFooterView{
    footerView = [[WalmartFooterView alloc]initWithFrame:CGRectMake(0, 660, 1020, 45)];
    [footerView create_common_Template:0];
    [footerView.annotateBtn addTarget:self action:@selector(selectAnnotateBtn:) forControlEvents:UIControlEventTouchDown];
    [footerView.exportBtn addTarget:self action:@selector(selectExportBtn:) forControlEvents:UIControlEventTouchDown];
    //Setting Actions for Annotate Buttons
    [footerView.shapesBtn addTarget:self action:@selector(drawShapes:) forControlEvents:UIControlEventTouchDown];
    [footerView.fontBtn addTarget:self action:@selector(changeFont:) forControlEvents:UIControlEventTouchDown];
    [footerView.pencilBtn addTarget:self action:@selector(getPencil:) forControlEvents:UIControlEventTouchDown];
    [footerView.cropBtn addTarget:self action:@selector(cropItem:) forControlEvents:UIControlEventTouchDown];
    [footerView.gradientBtn addTarget:self action:@selector(fillGradient:) forControlEvents:UIControlEventTouchDown];
    [footerView.undoBtn addTarget:self action:@selector(undoProcess:) forControlEvents:UIControlEventTouchDown];
    [footerView.redoBtn addTarget:self action:@selector(redoProcess:) forControlEvents:UIControlEventTouchDown];
    [footerView.saveBtn addTarget:self action:@selector(saveProcess:) forControlEvents:UIControlEventTouchDown];
    //Setting Actions for Export Buttons
    [footerView.pdfBtn addTarget:self action:@selector(createPdf:) forControlEvents:UIControlEventTouchDown];
    [footerView.jpgBtn addTarget:self action:@selector(createJpg:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:footerView];
    
}
-(void)addHeaderView{
    headerView = [[WalmartSelectionHeader alloc]initWithFrame:CGRectMake(0, 0, 1024, 743)];
    [self.view addSubview:headerView];
}

-(void)customColorsForLabels{
    //Textcolor codes for the Labels
    cumulativeSalesLabel.textColor = UIColorFromRGB(0xffffff);
    cumulativeTSSharesLabel.textColor = UIColorFromRGB(0xffffff);
    sateWiseCumSalesLAbel.textColor = UIColorFromRGB(0xffffff);
    clickOnEachLabel.textColor = UIColorFromRGB(0xffffff);
    totalEventSaleLabel.textColor = UIColorFromRGB(0x0f65bc);
    
}
-(void)hideLeftFooter
{
    footerView.shapesBtn.hidden =YES;
    footerView.fontBtn.hidden =YES;
    footerView.yellowBar.hidden=YES;
    footerView.pencilBtn.hidden =YES;
    footerView.cropBtn.hidden =YES;
    footerView.gradientBtn.hidden =YES;
    footerView.undoBtn.hidden =YES;
    footerView.redoBtn.hidden =YES;
    footerView.saveBtn.hidden =YES;
    footerView.pdfBtn.hidden =YES;
    footerView.jpgBtn.hidden =YES;
}
-(NSMutableData *)createPDFDatafromUIView:(UIView*)aView
{
    
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    aView.frame = CGRectMake(aView.frame.origin.x ,aView.frame.origin.y, aView.frame.size.width, aView.frame.size.height);
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [aView.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    return pdfData;
}

-(NSString *)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [self createPDFDatafromUIView:aView];
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:aFilename atomically:YES];
    return aFilename;
}
- (IBAction)stateSelected:(id)sender {
    button = (UIButton*)sender;
    point = CGPointMake(button.frame.origin.x+button.frame.size.width/3, button.frame.origin.y-30);
    [self setExclusiveSelectionForButtons:[[self.view subviews]objectAtIndex:0]];
    [sender setSelected:YES];
    NSDictionary *dict = [self fetchCountryDetails:[button titleForState:UIControlStateNormal]];
    StatePopOverView *vvv = [[StatePopOverView alloc]initWithFrame:CGRectMake(0, 0, 194, 60) withParameters:dict];
    pv = [PopoverView showPopoverAtPoint:point
                                  inView:self.view
                               withTitle:@""
                         withContentView:vvv
                                delegate:self]; // Show calendar with title
}

- (IBAction)businessUnitClicked:(id)sender {
    if([sender isKindOfClass:[NSString class]]){
        if ([sender isEqualToString:@"Walmart"]) {
            businessUnitObj = [[BusinessUnitViewController alloc]initWithNibName:@"BusinessUnitViewController" bundle:nil];
            businessUnitObj.buName=sender;
            businessUnitObj.buCumSales = [buCumSalesDict objectForKey:@"Walmart"];
            [headerView updateSbuTable:businessUnitObj.buName];
            [self.navigationController pushViewController:businessUnitObj animated:YES];
        }
        else if([sender isEqualToString:@"Sams Club"])
        {
//            UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for Sams Club" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertForNoData show];
             
            samsBusinessUnitObj=[[SamsClubBUViewController alloc]initWithNibName:@"SamsClubBUViewController" bundle:nil];
            samsBusinessUnitObj.buCumSales=[buCumSalesDict objectForKey:@"Sams Club"];
            [self.navigationController pushViewController:samsBusinessUnitObj animated:YES];
            
        }
        else if([sender isEqualToString:@".Com"])
        {
            UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for .Com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertForNoData show];
        }

        
        
    }
    else if([sender isKindOfClass:[UIButton class]])
    {
    UIButton *someButton = (UIButton*)sender;
    switch (someButton.tag) {
        case 10:
        {
            NSString *str = [sender titleForState:UIControlStateNormal];
            businessUnitObj = [[BusinessUnitViewController alloc]initWithNibName:@"BusinessUnitViewController" bundle:nil];
            businessUnitObj.buName=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            businessUnitObj.buName=str;
            businessUnitObj.buCumSales = [buCumSalesDict objectForKey:@"Walmart"];
            [headerView updateSbuTable:businessUnitObj.buName];
            [self.navigationController pushViewController:businessUnitObj animated:YES];

        }
            break;
        case 20:
        {
//            UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for Sams Club" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertForNoData show];
            samsBusinessUnitObj=[[SamsClubBUViewController alloc]initWithNibName:@"SamsClubBUViewController" bundle:nil];
            samsBusinessUnitObj.buCumSales=[buCumSalesDict objectForKey:@"Sams Club"];

            [self.navigationController pushViewController:samsBusinessUnitObj animated:YES];
            
        }
            break;

        case 30:{
            UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for .Com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertForNoData show];
        }
            break;
            
        default:
            break;
    }
  }
}

- (void)selectAnnotateBtn:(id)sender
{
    footerView.shapesBtn.hidden =NO;
    footerView.fontBtn.hidden =NO;
    footerView.yellowBar.hidden=NO;
    footerView.pencilBtn.hidden =NO;
    footerView.cropBtn.hidden =NO;
    footerView.gradientBtn.hidden =NO;
    footerView.undoBtn.hidden =NO;
    footerView.redoBtn.hidden =NO;
    footerView.saveBtn.hidden =NO;
    footerView.pdfBtn.hidden =YES;
    footerView.jpgBtn.hidden =YES;
    if (footerView.annotateBtn.isSelected) {
        footerView.annotateBtn.selected=NO;
        [self hideLeftFooter];
    }
    else{
        footerView.annotateBtn.selected=YES;
    }
    footerView.exportBtn.selected=NO;
    
    if (snap) {
        snap = NO;
        [self customizeHeaderViewScribbling];
        [self takeSnapCurrentView:@"STR"];
    }
}

- (void)selectAnnotateBtnClose:(id)sender
{
    footerView.shapesBtn.hidden =NO;
    footerView.fontBtn.hidden =NO;
    footerView.yellowBar.hidden=NO;
    footerView.pencilBtn.hidden =NO;
    footerView.cropBtn.hidden =NO;
    footerView.gradientBtn.hidden =NO;
    footerView.undoBtn.hidden =NO;
    footerView.redoBtn.hidden =NO;
    footerView.saveBtn.hidden =NO;
    footerView.pdfBtn.hidden =YES;
    footerView.jpgBtn.hidden =YES;
        footerView.annotateBtn.selected=NO;
        [self hideLeftFooter];
    footerView.exportBtn.selected=NO;
}
-(void)closeButtonPressed:(id)sender
{

    [UIView animateWithDuration:.5 animations:^{
        [objScribble setFrame:CGRectMake(0, -48+self.view.frame.size.height+48 , 1024, self.view.frame.size.height+48)];
    } completion:^(BOOL finished) {
        [objScribble removeFromSuperview];
    }];
    snap = YES;
    [self customizeHeaderView];
    [self selectAnnotateBtnClose:nil];
}

-(void)takeSnapCurrentView:(NSString*)sender
{
    //NSLog(@"printing hello");
    UIView *objWebView = self.view;
    UIGraphicsBeginImageContext(objWebView.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(c, 0, -48);    // <-- shift everything up by 40px when drawing.
    CGContextTranslateCTM(c, 0, 48);    // <-- shift everything up by 40px when drawing.
    [objWebView.layer renderInContext:c];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	// Inserting the .png file from Document Directory
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
	
	NSData *imageData = UIImagePNGRepresentation(image);
	[imageData writeToFile:savedImagePath atomically:YES];
	
	// retreiving the .png file from Document Directory
	
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
	
//	ScriblingView *objScribble=[[ScriblingView alloc] initWithFrame:CGRectMake(0, 48 , 1024, objWebView.frame.size.height) titleName:sender];
    objScribble=[[ScriblingView alloc] initWithFrame:CGRectMake(0, -48+objWebView.frame.size.height+48 , 1024, objWebView.frame.size.height+48) titleName:sender];
	
	objScribble.imageForScribble.image=img;
    [objWebView  addSubview:objScribble];

    [UIView animateWithDuration:.3 animations:^{
        [objScribble setFrame:CGRectMake(0, -48-48 , 1024, objWebView.frame.size.height+48)];
    }];
    
    //
    

}

- (void)selectExportBtn:(id)sender
{
    footerView.shapesBtn.hidden =YES;
    footerView.fontBtn.hidden =YES;
    footerView.yellowBar.hidden=YES;
    footerView.pencilBtn.hidden =YES;
    footerView.cropBtn.hidden =YES;
    footerView.gradientBtn.hidden =YES;
    footerView.undoBtn.hidden =YES;
    footerView.redoBtn.hidden =YES;
    footerView.saveBtn.hidden =YES;
    footerView.pdfBtn.hidden =NO;
    footerView.jpgBtn.hidden =NO;
    footerView.annotateBtn.selected=NO;
    if (footerView.exportBtn.isSelected) {
        footerView.exportBtn.selected=NO;
        [self hideLeftFooter];
    }
    else{
        footerView.exportBtn.selected=YES;
    }
}

-(void)settingsButtonPressed
{
    SettingsViewController *lineViewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    lineViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:lineViewController animated:YES completion:nil];
    lineViewController.view.superview.bounds = CGRectMake(0,0,416,530);
    
}
-(void)drawShapes:(id)sender{
   
}
-(void)changeFont:(id)sender{
    
}
-(void)getPencil:(id)sender{
    
}
-(void)cropItem:(id)sender{
   
}
-(void)fillGradient:(id)sender{
 
}
-(void)undoProcess:(id)sender{
    [objScribble undoButtonTapped];
}
-(void)redoProcess:(id)sender{
    [objScribble redoButtonTapped];
}
-(void)saveProcess:(id)sender{
   
}
-(void)createPdf:(id)sender{
    //Creating the PDF Path
    pageSize = CGSizeMake(612, 792);
    NSString *fileName = @"Walmart Annual Event.pdf";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    //Calling the Create PDF Method
    [self createPDFfromUIView:self.navigationController.view saveToDocumentsWithFileName:pdfFileName];
    fileURL = [NSURL fileURLWithPath:pdfFileName];
    //creating the object of the QLPreviewController
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    [[self navigationController] presentViewController:previewController animated:YES completion:nil];
    [previewController.navigationItem setRightBarButtonItem:nil];
}
-(void)createJpg:(id)sender{
    //Getting the Image in JPEG Format and Saving it to Documents Directory
    NSArray *dirPaths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *docsDir= [dirPaths objectAtIndex:0];
    NSString *jpegImagePath = [docsDir stringByAppendingPathComponent:@"ScreenImage.jpeg"];
    UIImage *image = [self ChangeViewToImage:self.view];
    NSData *data1 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
    [data1 writeToFile:jpegImagePath atomically:YES];
    
    //Load the retrieved image into a ModalViewController
    DisplayImageViewController *imageViewController = [[DisplayImageViewController alloc]initWithImage:image];
     [self presentViewController:imageViewController animated:YES completion:nil];
}
/**************************************************************************************/
#pragma mark- Touches Set 
/**************************************************************************************/
-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * button1 in [myView subviews]) {
        if([button1 isKindOfClass:[OBShapedButton class]]){
            [((UIButton *)button1) setExclusiveTouch:YES];
        }
    }
}
-(void)setExclusiveSelectionForButtons:(UIView *)myView
{
    for (UIButton * button1 in [myView subviews]) {
        if([button1 isKindOfClass:[OBShapedButton class]]){
            [button1 setSelected:NO];
        }
    }
}
/**************************************************************************************/
#pragma mark -
#pragma mark QLPreviewControllerDataSource
/**************************************************************************************/
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1; 
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return fileURL;
}
/**************************************************************************************/
#pragma mark- Piechart Content
/**************************************************************************************/
- (NSArray *)_demoSlices
{
    EGODatabaseResult* result = [database executeQueryWithParameters:@"SELECT BU, CAST(ROUND(AVG(CUM_TOTAL_TY)/100,2) AS INT) AS PERCE FROM TBL_BU_SBU_SALES_TYLY_HOURLY WHERE SALES_TIME = '2012-11-23 21:00:00' AND BU IN ('Walmart','Sams Club','.Com') GROUP BY BU", nil];
    NSMutableArray *arrayOne, *arrayTwo;
    arrayOne = [[NSMutableArray alloc]init];
    arrayTwo = [[NSMutableArray alloc]init];
    for(EGODatabaseRow* row in result) {
        [arrayOne addObject:[row stringForColumn:@"BU" ]];
        [arrayTwo addObject:[row stringForColumn:@"PERCE"]];
    }
    TBMSlice *firstSlice = [TBMSlice sliceWithColor:UIColorFromRGB(0xc17e08) percentage:[[arrayTwo objectAtIndex:0] doubleValue] name:[arrayOne objectAtIndex:0]];
	TBMSlice *secondSlice = [TBMSlice sliceWithColor:UIColorFromRGB(0x73b61b) percentage:[[arrayTwo objectAtIndex:1] doubleValue] name:[arrayOne objectAtIndex:1]];
    TBMSlice *thirdSlice = [TBMSlice sliceWithColor:UIColorFromRGB(0x0f65bc) percentage:[[arrayTwo objectAtIndex:2] doubleValue] name:[arrayOne objectAtIndex:2]];
    return [NSArray arrayWithObjects:firstSlice,thirdSlice,secondSlice, nil];
}
/**************************************************************************************/
- (TBMChartView *)_chartView
{
	CGRect viewFrame = CGRectMake(0., 25., self.pieChartView.frame.size.width, self.pieChartView.frame.size.width);
	TBMChartView *chart = [[TBMChartView alloc] initWithFrame:viewFrame];
	return chart;
}

/**************************************************************************************/
#pragma mark- Orientation handling
/**************************************************************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft| UIInterfaceOrientationLandscapeRight);
}
-(BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight);
}
/**************************************************************************************/
#pragma mark- General methods &
- (NSDictionary*)fetchCountryDetails:(NSString*)stateCode {
    EGODatabaseResult* result = [database executeQueryWithParameters:@"SELECT BU, A.STATE_CODE, STATE_NAME, STATE_BU_SALES FROM TBL_STATE_SALES A, TBL_STATE_CODE_NAME B WHERE A.STATE_CODE= ? AND A.STATE_CODE = B.STATE_CODE",stateCode, nil];
    NSMutableArray *arrayOne, *arrayTwo, *arrayThree;
    arrayOne = [[NSMutableArray alloc]init];
    arrayTwo = [[NSMutableArray alloc]init];
    arrayThree = [[NSMutableArray alloc]init];
    for(EGODatabaseRow* row in result) {
        [arrayOne addObject:[row stringForColumn:@"BU" ]];
        [arrayTwo addObject:[row stringForColumn:@"STATE_NAME"]];
        [arrayThree addObject:[row stringForColumn:@"STATE_BU_SALES"]];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:@[arrayOne, arrayTwo, arrayThree] forKeys:@[@"BU",@"STATE_NAME",@"STATE_BU_SALES"]];
    return dict;
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView;
{
    [button setSelected:![button isSelected]];
}

-(UIImage *) ChangeViewToImage : (UIView *) view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)loadData
{
    //EGODatabaseResult* result = [database executeQueryWithParameters:@"SELECT * FROM `Friday_22` WHERE `Department_Number` = ?", [NSNumber numberWithInt:7], nil];
    EGODatabaseResult* result = [database executeQueryWithParameters:@"SELECT BU, CUM_TOTAL_TY,CUM_TOTAL_LY FROM TBL_BU_SBU_SALES_TYLY_HOURLY WHERE SALES_TIME = '2012-11-23 21:00:00' AND BU IN ('Walmart','Sams Club','.Com')",nil];
    
    NSMutableArray *arrayOne, *arrayTwo, *arrayThree;
    arrayOne = [[NSMutableArray alloc]init];
    arrayTwo = [[NSMutableArray alloc]init];
    arrayThree = [[NSMutableArray alloc]init];
    
    for(EGODatabaseRow* row in result)
    {
        [arrayOne addObject:[row stringForColumn:@"BU" ]];
        [arrayTwo addObject:[NSNumber numberWithDouble:[row doubleForColumn:@"CUM_TOTAL_TY"]]];
        [arrayThree addObject:[NSNumber numberWithDouble:[row doubleForColumn:@"CUM_TOTAL_LY"]]];
    }
    pointArr = [[NSMutableArray alloc]init];
    [pointArr addObject:[NSNumber numberWithFloat:150]];
    [pointArr addObject:[NSNumber numberWithFloat:146]];
    [pointArr addObject:[NSNumber numberWithFloat:156]];
    
    dataArray1 =         [NSArray arrayWithArray:arrayTwo];
    dataArray2 =         [NSArray arrayWithArray:arrayThree];
    xisLabel =           [NSArray arrayWithArray:arrayOne];
}

-(void)setupBarChart
{
    NSArray *gt;
    barchartView = [[BarChartView alloc]initWithFrame:CGRectMake(10, 0, 380, 280)];
    g = [NSArray arrayWithObjects:dataArray1, dataArray2, nil];
    NSArray *ct = [NSArray arrayWithObjects:@"Item Discount Amt", nil];
    
	barchartView.groupData = g;
    barchartView.groupTitle = gt;
    barchartView.xAxisLabel = xisLabel;
    barchartView.chartTitle = ct;
    barchartView.backgroundColor = [UIColor clearColor];
    barchartView.chartType = 2;
    barchartView.columnScaleFactor = 30;
    barchartView.columnWidth = 20;
    barchartView.lineAxis = 20;
    barchartView.marginScaleBetween = 8;
    barchartView.delegate = self;
    [barchartView setUserInteractionEnabled:YES];
    [self.barChartImageView addSubview:barchartView];
}

-(void)setUpLineChart
{
    lineChartView = [[LineChart alloc]initWithFrame:CGRectMake(10, 0, 380, 280)];
    [lineChartView setArray:[NSArray arrayWithObjects:pointArr, nil]];
    [lineChartView setBackgroundColor:[UIColor clearColor]];
    lineChartView.chartType = 2;
    lineChartView.columnScaleFactor = 60;
    lineChartView.columnWidth = 20;
    barchartView.marginScaleBetween = 8;
    lineChartView.xAxisLabel = xisLabel;
    lineChartView.delegate = self;
    [lineChartView setUserInteractionEnabled:YES];
    [self.barChartImageView addSubview:lineChartView];
}

- (IBAction)displayIndividualYearSales:(id)sender
{
    [barchartView removeFromSuperview];
    [lineChartView removeFromSuperview];

    if ((((UIButton *)sender).tag == 1)||(((UIButton *)sender).tag == 2))
    {
        barchartView = [[BarChartView alloc]initWithFrame:CGRectMake(10, 0, 380, 280)];
    g = [NSArray arrayWithObjects:dataArray1,dataArray2, nil];
    barchartView.firstColumn = YES;
    barchartView.secondColumn = YES;
    if (((UIButton *)sender).tag == 1)
    {
        barchartView.firstColumn = NO;
    }
    else if(((UIButton *)sender).tag == 2)
    {
        barchartView.secondColumn = NO;
    }
    barchartView.chartType = 2;
    barchartView.groupData = g;
    barchartView.xAxisLabel = xisLabel;
    barchartView.backgroundColor = [UIColor clearColor];
    barchartView.columnWidth = 20;
    barchartView.columnScaleFactor = 30;
    barchartView.marginScaleBetween = 8;
    barchartView.delegate = self;
    [self.barChartImageView addSubview:barchartView];
    [self.barChartImageView bringSubviewToFront:barchartView];
    }
    else if(((UIButton *)sender).tag == 3)
    {
        lineChartView = [[LineChart alloc]initWithFrame:CGRectMake(10, 0, 380, 280)];
        [lineChartView setArray:[NSArray arrayWithObjects:pointArr, nil]];
        [lineChartView setBackgroundColor:[UIColor clearColor]];
        lineChartView.chartType = 2;
        lineChartView.xAxisLabel = xisLabel;
        lineChartView.columnScaleFactor = 40;
        lineChartView.columnWidth = 25;
        lineChartView.delegate = self;
        lineChartView.xAxisWidth = 3;
        lineChartView.marginScaleBetween = 20;
        lineChartView.lineChartTypeView = KLineChartView;
        [self.barChartImageView addSubview:lineChartView];

    }
    else if (((UIButton *)sender).tag == 4)
    {
        [self setupBarChart];
        [self setUpLineChart];
    }
}



-(void)getTheEventBarChartImageView:(UITapGestureRecognizer*)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    switch (gesture.view.tag) {
        case 10:
            [self getTheEventBarChart:@"Walmart"];
            break;
        case 20:
            [self getTheEventBarChart:@"Sams Club"];
            break;
        case 30:
            [self getTheEventBarChart:@".Com"];
            break;
            
        default:
            break;
    }
    
}

- (void)getTheEventBarChart:(NSString *)string;
{
//    businessUnitObj = [[BusinessUnitViewController alloc]initWithNibName:@"BusinessUnitViewController" bundle:nil];
//    
//    if ([string isEqualToString:@"Walmart"]) {
//        
//        businessUnitObj.buName=string;
//
//        
//[self businessUnitClicked:string];
////        [self.navigationController pushViewController:businessUnitObj animated:YES];
//        
//    }
//    else if([string isEqualToString:@"Sams Club"])
//    {
//    UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for Sams Club " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertForNoData show];
//    }
//    else if([string isEqualToString:@".Com"])
//    {
//    UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for .Com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertForNoData show];
//    }
    [self businessUnitClicked:string];

}

- (void)getTheEventPieChart:(NSString *)string{
//    businessUnitObj = [[BusinessUnitViewController alloc]initWithNibName:@"BusinessUnitViewController" bundle:nil];
//    
//    if ([string isEqualToString:@"Walmart"]) {
//        
//        businessUnitObj.buName=string;
//        //businessUnitObj.buCumSales=[arra]
//        [headerView updateSbuTable:string];
//        [self businessUnitClicked:string];
//        //        [self.navigationController pushViewController:businessUnitObj animated:YES];
//        
//    }
//    else if([string isEqualToString:@"Sams Club"])
//    {
//        UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for Sams Club" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertForNoData show];
//    }
//    else if([string isEqualToString:@".Com"])
//    {
//        UIAlertView *alertForNoData = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Data available for .Com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertForNoData show];
//    }
    [self businessUnitClicked:string];
    
}
- (void)viewDidUnload {
   
    [self setWalmartImageView:nil];
    [self setSalesClubImageView:nil];
    [self setDotComImageView:nil];
    [super viewDidUnload];
}

    @end
