//
//  main.m
//  SpellCheckFile
//
//  Created by Anson Liu on 9/5/16.
//  Copyright © 2016 Anson Liu. All rights reserved.
//

//Used to delete intentional misspellings from Opinion Lexicon by Minqing Hu and Bing Liu obtained from https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html.

@import AppKit;

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
        //NSArray *availableLanguages = [spellChecker userPreferredLanguages];
        //NSString *preferredLanguage = (availableLanguages.count > 0 ? availableLanguages[0] : @"en");
        
        FILE *file = fopen("/Users/ansonl/Desktop/words.txt", "r");
        FILE *tmpFile = fopen("/Users/ansonl/Desktop/output.txt", "w");
        
        size_t length;
        char *line;
        line = fgetln(file, &length);
        while (length > 0) {
            char readLine[length+1];
            strlcpy(readLine, line, length);
            readLine[length] = '\0';
            NSString *someText = [NSString stringWithFormat:@"%s", readLine];
            
            NSRange check = [spellChecker checkSpellingOfString:someText startingAt:0];
            
            //If no misspelling found, write to tmp file.
            if (check.location == NSNotFound) {
                NSString *writeBackLine = [NSString stringWithFormat:@"%@\n", someText];
                fputs([writeBackLine cStringUsingEncoding:NSUTF8StringEncoding], tmpFile);
            }
            line = fgetln(file, &length);
        }
    }
    return 0;
}
