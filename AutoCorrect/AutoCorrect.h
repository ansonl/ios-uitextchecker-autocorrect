//
//  AutoCorrect.h
//  ComboKeyboard
//
//  Created by Anson Liu on 9/4/16.
//  Copyright © 2016 Anson Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCorrect : NSObject

- (void)learnLexicon:(UILexicon *)lexicon;
- (BOOL)autoCorrectTextDocument:(id<UITextDocumentProxy>)textDocumentProxy;

@end
