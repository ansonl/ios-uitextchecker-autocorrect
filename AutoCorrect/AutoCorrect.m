//
//  AutoCorrect.m
//  ComboKeyboard
//
//  Created by Anson Liu on 9/4/16.
//  Copyright © 2016 Anson Liu. All rights reserved.
//

#import "AutoCorrect.h"

@implementation AutoCorrect {
    UITextChecker *textCheckerInstance;
}

- (instancetype)init {
    self = [super init];
    if (self)
        textCheckerInstance = [[UITextChecker alloc] init];
    return self;
}

- (void)learnLexicon:(UILexicon *)lexicon {
    for (UILexiconEntry *entry in lexicon.entries) {
        if (![UITextChecker hasLearnedWord:entry.userInput])
            [UITextChecker learnWord:entry.userInput];
    }
}

//Return if a correction is made
- (BOOL)autoCorrectTextDocument:(id<UITextDocumentProxy>)textDocumentProxy {
    NSString *inputText = [textDocumentProxy documentContextBeforeInput];
    if (inputText == nil) {
        return false;
    }
    
    //get range of last space in input
    NSRange lastSpaceRange = [inputText rangeOfString:@" " options:NSBackwardsSearch];
    
    //Check if there is no space in the text. Start at beginning of input text. NSRange is NSUInteger, but we will just set the raw value to -1 which = NSNotFound.
    if (lastSpaceRange.location == NSNotFound) {
        lastSpaceRange = NSMakeRange(-1, 0);
    }
    
    //Check if last space is at the end (last character) of the inputText
    if ((int)lastSpaceRange.location - (int)inputText.length == -1) {
        return false;
    }
    
    int lookbackLimit = 2;
    int lookbackAmount = 1; //already found last space above
    //look back as far as we can to find words separated by spaces
    NSRange startSpaceRange = lastSpaceRange;
    do {
        long int lookbackFromIndex = startSpaceRange.location;
        if (lookbackFromIndex < 0)
            lookbackFromIndex = 0;
        startSpaceRange = [[inputText substringToIndex:lookbackFromIndex] rangeOfString:@" " options:NSBackwardsSearch];
        lookbackAmount++;
    } while (startSpaceRange.location != NSNotFound && lookbackAmount < lookbackLimit);
    
    //The start space couldn't be found at lookback amount. Use the start of the input text.
    if (startSpaceRange.location == NSNotFound)
        startSpaceRange.location = -1;
    
    //the start space is 1 character before the last space
    if ((int)startSpaceRange.location - (int)lastSpaceRange.location == -1) {
        startSpaceRange = lastSpaceRange;
    }
    
    NSArray *languages = [UITextChecker availableLanguages];
    NSString *preferredLanguage = (languages.count > 0 ? languages[0] : @"en-US");
    
    NSRange shortMisspelled = [textCheckerInstance rangeOfMisspelledWordInString:inputText range:NSMakeRange((int)lastSpaceRange.location+1, inputText.length-((int)lastSpaceRange.location+1)) startingAt:0 wrap:NO language:preferredLanguage];
    
    //Last word not misspelled, do nothing
    if (shortMisspelled.location == NSNotFound)
        return false;
    
    NSString *replacementString;
    NSRange replacementRange;
    
    NSLog(@"long guess range %@", [inputText substringWithRange:NSMakeRange((int)startSpaceRange.location+1, inputText.length-((int)startSpaceRange.location+1))]);
    NSLog(@"short guess range %@", [inputText substringWithRange:NSMakeRange((int)lastSpaceRange.location+1, inputText.length-((int)lastSpaceRange.location+1))]);
    
    //Try to find guesses for long lookback. Add 1 to range location because the location is index is of the space.
    NSArray *longGuesses = [textCheckerInstance guessesForWordRange:NSMakeRange((int)startSpaceRange.location+1, inputText.length-((int)startSpaceRange.location+1)) inString:inputText language:preferredLanguage];
    if (longGuesses.count > 0) {
        replacementString = longGuesses[0];
        replacementRange = NSMakeRange((int)startSpaceRange.location+1, inputText.length-((int)startSpaceRange.location+1));
    } else { //Try to find guess for short lookback if long lookback has no guesses
        NSArray *shortGuesses = [textCheckerInstance guessesForWordRange:NSMakeRange((int)lastSpaceRange.location+1, inputText.length-((int)lastSpaceRange.location+1)) inString:inputText language:preferredLanguage];
        
        if (shortGuesses.count > 0) {
            replacementString = shortGuesses[0];
            replacementRange = NSMakeRange((int)lastSpaceRange.location+1, inputText.length-((int)lastSpaceRange.location+1));
        }
    }
    
    /*
    if (replacementString)
        NSLog(@"replace range %@", [inputText substringWithRange:replacementRange]);
    else
        NSLog(@"no replace");
     */
    
    //Return nil if no guesses
    if (replacementString == nil)
        return false;
    
    
    
    for (int i = 0; i < replacementRange.length; i++) {
        NSLog(@"%d", i);
        [textDocumentProxy deleteBackward];
    }
    
    [textDocumentProxy insertText:replacementString];
    
    return true;
}

@end
