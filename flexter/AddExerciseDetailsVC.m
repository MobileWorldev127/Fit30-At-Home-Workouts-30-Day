//
//  AddExerciseDetailsVC.m
//  flexter
//
//  Created by Anurag Tolety on 9/1/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import "AddExerciseDetailsVC.h"
#import "FDConstants.h"
#import "UIConstants.h"

@interface AddExerciseDetailsVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *muscleTargetsView;
@property (weak, nonatomic) IBOutlet UIButton *createExerciseButton;
@property (weak, nonatomic) IBOutlet UITextField *exerciseTitleTextField;
@property (weak, nonatomic) IBOutlet UISwitch *homeExerciseSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *exerciseCoverImageView;
@property int selectedMuscleCategory;

@end

@implementation AddExerciseDetailsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.createExerciseButton setEnabled:NO];
    self.createExerciseButton.titleLabel.textColor = [UIColor lightGrayColor];
    self.exerciseTitleTextField.delegate = self;
    self.exerciseCoverImageView.clipsToBounds = YES;
    self.exerciseCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
    self.muscleTargetsView.delegate = self;
    self.muscleTargetsView.dataSource = self;
    [self.muscleTargetsView reloadData];
    self.selectedMuscleCategory = -1;
    self.exerciseCoverImageView.image = self.exerciseCoverImage;
}

- (void)tapAction
{
    [self.exerciseTitleTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)conditionallyEnableCreateExercise
{
    if (self.exerciseTitleTextField.text && ![self.exerciseTitleTextField.text isEqualToString:@""] && (self.selectedMuscleCategory != -1)) {
        [self.createExerciseButton setEnabled:YES];
        self.createExerciseButton.titleLabel.textColor = APP_THEME_COLOR;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self conditionallyEnableCreateExercise];
}

- (NSString*)textForMuscleCategory:(int)muscleCategory
{
    switch (muscleCategory) {
        case MUSCLE_CATEGORY_ABS:
            return @"Abs";
            break;
            
        case MUSCLE_CATEGORY_BACK:
            return @"Back";
            break;
            
        case MUSCLE_CATEGORY_BICEPS:
            return @"Biceps";
            break;
            
        case MUSCLE_CATEGORY_BUTT:
            return @"Butt";
            break;
            
        case MUSCLE_CATEGORY_CALVES:
            return @"Calves";
            break;
        
        case MUSCLE_CATEGORY_CARDIO:
            return @"Cardio";
            break;
            
        case MUSCLE_CATEGORY_CHEST:
            return @"Chest";
            break;
            
        case MUSCLE_CATEGORY_LEGS:
            return @"Legs";
            break;
            
        case MUSCLE_CATEGORY_SHOULDERS:
            return @"Shoulders";
            break;
            
        case MUSCLE_CATEGORY_TRICEPS:
            return @"Triceps";
            break;
            
        case MUSCLE_CATEGORY_FULLBODY:
            return @"Full Body";
            break;
            
        case MUSCLE_CATEGORY_OTHER:
            return @"Other";
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MUSCLE_CATEGORY_COUNT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MuscleTargetCell"];
    cell.textLabel.text = [self textForMuscleCategory:(int)indexPath.row];
    if (self.selectedMuscleCategory == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"AddExerciseDetailsVC selected");
    ((UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedMuscleCategory = indexPath.row;
    [self conditionallyEnableCreateExercise];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"AddExerciseDetailsVC deselected");
    ((UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryNone;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)createExerciseButtonPressed:(id)sender {
    self.exercise[EXERCISE_TITLE] = self.exerciseTitleTextField.text;
    self.exercise[EXERCISE_MUSCLE_CATEGORY] = [NSNumber numberWithInteger:self.selectedMuscleCategory];
    self.exercise[EXERCISE_HOME_WORKOUT] = [NSNumber numberWithBool:self.homeExerciseSwitch.on];
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.createExerciseButton.titleLabel.text = @"";
    [self.createExerciseButton addSubview:spinner];
    [self.exercise saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        self.createExerciseButton.titleLabel.text = @"CREATE EXERCISE";
        self.createExerciseButton.titleLabel.tintColor = APP_THEME_COLOR;
        if (!succeeded) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to create exercise. Check network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
