#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *encryptCoreDataSwitch;
@property (weak, nonatomic) IBOutlet UIButton *initializeCoreDataBtn;
@property (weak, nonatomic) IBOutlet UIButton *restCoreDataBtn;
@property (weak, nonatomic) IBOutlet UIButton *startMigrationBtn;

@end