//
//  ContentView.swift
//  WordScramble
//
//  Created by Nestor Trillo on 3/20/21.
//
//  GOAL: create a game that shows a "root" word to the user and lets the user make a list of other words using the letters from  the root word.
//  INPUT: 1. a random root word from a text file, 2. a new word typed in by the user
//  OUTPUT: a list of words using the letters from the provided root word
//
//

// imports a library called "SwiftUI" for the user interface
import SwiftUI

// create a structure called ContentView where we can View Content. Real world example: a Theatre.
struct ContentView: View {
    // Variables : usedWords is a string array containing the list of words the user has entered before. rootWord is the word we pull from a resource file. newWord is the current word entered by the user.
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    // showing error will require 3 things: a title for error window, the error message, and variable to indicate if we should show an error message or not.
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    // the body is where all content is presented to the user. Real world example: a stage or screen inside the theatre.
    var body: some View {
        // To simplify layout on the screen we use a "NavigationView"
        NavigationView {
            // VStacl is a vertical stack of content on the screen like blocks stacked on top of each other
            VStack{
                // shows a text field where user can enter a new word. Field is connected to the variable "newWord" and when the user submits a new word, it triggers the function called "addNewWord"
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // makes the field prettier
                    .autocapitalization(.none) // turns off automatic capitalization of words
                    .padding() // adds some space around the field to make it easier to read
               // this is a list of words the user has already submitted and stored. This list loops over the stored items and uses the word itself as the unique id.
                List(usedWords, id: \.self) {
                    // first, the list displays a character count displayed as a number inside a circle
                    Image(systemName: "\($0.count).circle")
                    Text($0) // the word the user entered
                }
            }
            .navigationBarTitle(rootWord) // displays the current word pulled from the resource file
            .onAppear(perform: startGame) // calls function "startGame" when this view appears
            // if variable called "showingError" is TRUE then show error
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    //FUNCTIONS
    func addNewWord() {
        // newWord is lowercased then trimmed by removing whitespaces and new lines
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // IF the number of answers is greater than zero the function continues ELSE stop and return
        guard answer.count > 0 else {
            return
        }
        
        // IF the new word is original continue, ELSE display the appropriate error message
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        // IF the new word can be spelled using the letters from the root word continue, ELSE display the appropriate error message
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        // IF the new word is in the dictionary continue, ELSE display the appropriate error message
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        // the new word has passed all the checks made by the guards above, so save it to the onscreen list
        usedWords.insert(answer, at: 0)
        // reset new word
        newWord = ""
    }
    
    func startGame(){
        // 1. identify source location,
        // 2. then get the contents as a string of text
        // 3. then break up the single string of text into words
        // 4. finally, grab a random word or use a default word
        // IF possible, LET startWordsURL be set to "start.txt" file inside this app's resource bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // and then, IF possible LET startWords be set to contents of the file. Try to format the content as a string or return Nil if you cannot.
            if let startWords = try? String(contentsOf: startWordsURL){
                // take the long string of text and seperate the words out by the newline character. This converts a long "sentence" of characters into a "vertical" list of words.
                let allWords = startWords.components(separatedBy: "\n")
                // THIS is what we are trying to arrive at after all the checks. Make rootWord set to a random word from the start.txt file, otherwise default to "rugrat"
                rootWord = allWords.randomElement() ?? "rugrat"
                return
            }
        }
        // one of the steps above failed, so show an error.
        fatalError("Could not load start.txt file from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        // returns "true" if the word submitted by user is not already in list of used words
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        // a temporary copy of the root word we can examine
        var tempWord = rootWord
        // check each letter of the word submitted for a matching letter in the root word. If at any time no matching letter is found return "False". If all letters match, the loop will exit.
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        // the loop above exited. all letters were matched which means the new word can be spelled using the letters from the root word, therefore return "True"
        return true
    }
    
    // check if the word exists in the English Dictionary. CHALLENGE: this code relies on the older/uglier programming language called "Objective C" to access the dictionary. 
    func isReal(word: String) -> Bool {
        // grab a copy of the ugly text checking function
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    //  a function to match up our error variable names on the left with the system's variable on the right
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
