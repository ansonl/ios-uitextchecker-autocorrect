#### iOS Autocorrect using UITextChecker

`AutoCorrect` class is an implementation of autocorrect using UITextChecker. Useful for iOS apps or custom keyboard extensions requiring autocorrect functionality.

#####**`AutoCorrect` class can be used with Swift!**

First initialize the AutoCorrect object:
```
let autoCorrectObject: AutoCorrect = AutoCorrect.init()
```

If you are building a keyboard extension, using a subclass of `KeyboardViewController`, and want to learn the OS provided supplementary lexicon (contacts' names):
```
//learn all names words from UILexicon
self.requestSupplementaryLexiconWithCompletion({
    lexicon in
    self.autoCorrectObject.learnLexicon(lexicon)
})
```

And run autocorrect when the user types a *space* or *newline*:
```
override func keyPressed(key: Key) {
    let keyOutput = key.outputForCase(self.shiftState.uppercase())

    NSLog(String(keyOutput))
    //trigger autocorrect on space and newline
    if keyOutput == " " || keyOutput == "\n" {
        if (self.autoCorrectObject.autoCorrectTextDocument(self.textDocumentProxy)) {
            self.banner.wordMisspelled()
        }
    }
    
    //UITextChecker marks 25 letter words as no misspelling so we check for it ourselves
    NSLog(String(ComboboardLogic.lengthOfLastWord(self.textDocumentProxy.documentContextBeforeInput)))
    if (ComboboardLogic.lengthOfLastWord(self.textDocumentProxy.documentContextBeforeInput) > 24) {
        self.banner.wordMisspelled()
    }
    
    //tell combo banner that key pressed
    banner.textKeyPress()
    self.textDocumentProxy.insertText(keyOutput)
}
```

If implemented this way, misspelled words will be autocorrected with the first guess provided by `UITextChecker`'s `guessesForWordRange`. With some modification, one can easily recreate a "predictive keyboard top bar". This is meant to be a starting point for implementing your own flavor of autocorrect. 

I used this implementation of autocorrect in [Combo Keyboard](https://itunes.apple.com/us/app/combo-keyboard/id1150809617?mt=8), a keyboard extension, for iOS. My app used the top space of the keyboard for other UI elements (no space for prediction bar) so you can understand why my provided implementation works the way it does. 

Apple's documentation states that the returned guesses
> ...are in the order they should be presented to the user—that is, more probable guesses come first in the array.

Unlike macOS, this is **not** the case on iOS, the returned guesses are closer to being in alphabetical order. 

#### Autocorrecting text lists with SpellCheckFile

`main.m` in `SpellCheckFile/` directory is a command line program for macOS that uses `NSSpellChecker` to remove misspelled words from a list words. The list is a text file consisting of one word per line.

1. Edit `file` and `tmpFile` variables in `main.m` to set the input and output file paths. 
2. Build and run

Example input file:
```
correct
correctt
icorrect
incorrect
```
will result in output file:
```
correct
correct
incorrect
incorrect
```

`SpellCheckFile` was used to delete intentional misspellings from Opinion Lexicon by Minqing Hu and Bing Liu obtained from [https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html](https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html).