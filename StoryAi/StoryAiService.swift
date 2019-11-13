//
//  StoryAiService.swift
//  StoryAi
//
//  Created by Cesa Salaam on 4/21/19.
//  Copyright © 2019 Cesa Salaam. All rights reserved.
//

import UIKit
import NaturalLanguageUnderstanding
import Alamofire
class StoryAiService: NSObject {
    static let storyAI = StoryAiService()
    
    let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(version: "2018-11-16", apiKey: "iTxVCHk6iO8Y0mnF-BzWraBDcJXb86OaApnajVdEHIbq")
    let features = Features(concepts: ConceptsOptions(limit: 5))
    let text = "you are ugly"
    
    let intro = "Hey, welcome to StoryAi. The place where stories come to life."
    
    let exposition = ["One day, a boy was digging in his garden, when he saw a big toe sticking out of the ground. He tried to pick it up, but it was stuck. It wouldn’t budge, so he pulled as hard as he could and it came off in his hand. Then he heard something groan and scamper away."]
    let risingAct = ["The boy took the big toe into the kitchen and showed it to his mom. \"That looks nice piece of meat,\" she said. \"I’ll put it in the soup, and we’ll have it for dinner.\"","That night, at the dinner table, the boy’s father scooped the big toe out of the soup and chopped it up into three pieces. The father, the mother and the boy each ate a piece. Then they did the dishes, and when it got dark they went to bed. The boy fell asleep almost at once. But in the middle of the night, he was rudely awakened by a strange sound. He listened closely. It sounded like there was a voice coming from outside his window and it was calling to him.", "\"Where is my big toe?\" it groaned. When the boy heard that, he got very scared. But he thought, \"It doesn’t know where I am. It never will find me.\" Then he heard the voice once more. Only now it was closer. \"Where is my big toe?\" it groaned. The boy pulled the blankets over his head and closed his eyes. \"I’ll go to sleep,\" he thought. \"When I wake up it will be gone. But soon he heard the back door open, and again he heard the voice."]
    
    let middle = ["\"Where is my big toe?\" it groaned. Then the boy heard footsteps move through the kitchen into the dining room, into the living room, into the front hall. They slowly climbed the stairs. Closer and closer they came. Soon they were in the upstairs hall. Now they were outside his door. \"Where is my toe?\" the voice groaned."]
    let niceEnding = ["The boy called out to his parents screaming for help! They instantly appeared in his room, asking what was wrong. He told them about the voice and so his dad went outside to see what it was. When his dad came back inside, the boy saw one of his practical joker of a friend walking behind him. He friend was just playing a trick on him!"]
    let scaryEnding = ["The boy watched in horror as his bedroom door opened. Shaking with fear, he threw his bedclothes over his head and listened as the footsteps slowly moved through the dark towards his bed. Then they stopped. Finally, he asks: \"W-w-w-what you got such big eyes for?\" The creature answers: \"To look you thro-o-o-ugh and thro-o-o-ugh!\" \"W-w-w-what you got such big claws for?” \"To scra-a-a-tch up your gra-a-a-a-ve!\" \"W-w-w-what you got such a big mouth for?\" \"To swallow you who-o-o-le!\" \"W-w-w-what you got such sharp teeth for?\" \"TO CHOMP YOUR BONES!\""]
    
    override init() {
        //naturalLanguageUnderstanding.serviceURL = "https://gateway-wdc.watsonplatform.net/natural-language-understanding/api"
    }
    
    func sentimentAnalysis(userInput: String, completionHandler: @escaping (_ myvalue: Bool)->Void){
        let parameters = ["text": userInput]
        var storyLine = [" "]
        AF.request("http://localhost:5000/analysis", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print("=-----= : \(response.result)")
            if response.data != nil{
                let newAnalysis = response.value as! NSDictionary
                let full = newAnalysis["analysis"] as! NSDictionary
                let emotion = full["emotion"] as! NSDictionary
                let document = emotion["document"] as! NSDictionary
                let realEmo = document["emotion"] as! NSDictionary
                var anger = realEmo["anger"] as? NSNumber
                let disgust = realEmo["disgust"]! as? NSNumber
                let fear = realEmo["fear"]! as? NSNumber
                let joy = realEmo["joy"]! as? NSNumber
                let sadness = realEmo["sadness"]! as? NSNumber
                let theEmotion = self.myEmotionis(anger: (anger?.floatValue)! , disgust: (disgust?.floatValue)!, fear: (fear?.floatValue)!, joy: joy!.floatValue, sadness: sadness!.floatValue)
                
                
                if (theEmotion == "joy"){
                    
                    DispatchQueue.main.async {
                        print("continue story as is because the emotion is positive \(theEmotion)")
                        storyLine = self.storyLine(change: false) //True because the person is enjoying the story. Emotion is joy
                        completionHandler(false)
                    }
                }else{
                    DispatchQueue.main.async {
                        print("nicer story line because the emotion is negative \(theEmotion)")
                        storyLine = self.storyLine(change: true) //False (Stay the same) becasue the person is too scared. The emotion is other than joy.
                        completionHandler(true)
                    }
                }
            }
        }
    }
    
    func myEmotionis(anger: Float, disgust: Float, fear: Float, joy: Float, sadness: Float)-> String{
        let largest = max(max(max(max(anger,disgust),fear),joy),sadness)
        print("this is the largest number: \(largest)")
        let emotions = [anger, disgust, fear, joy, sadness]
        switch largest{
        case emotions[0]:
            print("the max emotion is anger")
            return "anger"
        case emotions[1]:
            print("the max emotion is disgust")
            return "disgust"
        case emotions[2]:
             print("the max emotion is fear")
            return "fear"
        case emotions[3]:
            print("the max emotion is joy")
            return "joy"
        case emotions[4]:
            print("the max emotion is saddness")
            return "sadness"
        default:
            print("couldnt find max so just using joy.")
            return "joy"
            
        }
    }
    
    func storyLine(change: Bool) -> [String]{
        var storyLine = self.exposition
        if change{
            print("story line value: \(change)")
            storyLine.append(contentsOf: self.risingAct)
            storyLine.append(contentsOf: self.middle)
            storyLine.append(contentsOf: self.scaryEnding)
            print("changed story line: \(storyLine)")
            return storyLine
        }else{
            print("story line value: \(change)")
            storyLine.append(contentsOf: self.risingAct)
            storyLine.append(contentsOf: self.middle)
            storyLine.append(contentsOf: self.niceEnding)
            print("story line: \(storyLine)")
            return storyLine
        }
        
    }
    
}
