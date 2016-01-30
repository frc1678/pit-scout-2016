import Foundation
// iOS Schema 2016

class Competition {
    var code = ""
    var teams : [Team] = []
    var matches : [Match] = []
    var TIMDs : [TeamInMatchData] = []
    var averageScore : Int = -1
}

class CalculatedTeamData {
    var driverAbility = -1
    var highShotAccuracyAuto = -1.0
    var lowShotAccuracyAuto = -1.0
    var highShotAccuracyTele = -1.0
    var lowShotAccuracyTele = -1.0
    var avgGroundIntakes = -1.0
    var avgHighShotsTele = -1.0
    var avgLowShotsTele = -1.0
    var avgShotsBlocked = -1.0
    var avgHighShotsAuto = -1.0
    var avgLowShotsAuto = -1.0
    var avgMidlineBallsIntakedAuto = -1.0
    var avgBallsKnockedOffMidlineAuto = -1.0
    var avgTorque = -1.0
    var avgSpeed = -1.0
    var avgEvasion = -1.0
    var avgDefense = -1.0
    var avgBallControl = -1.0
    var disfunctionalPercentage = -1.0
    var reachPercentage = -1.0
    var disabledPercentage = -1.0
    var incapacitatedPercentage = -1.0
    var scalePercentage = -1.0
    var challengePercentage = -1.0
    var avgDefenseCrossingEffectiveness = ["pc" : -1.0,"cdf" : -1.0,"mt" :  -1.0,"rp" : -1.0,"sp" : -1.0,"db" : -1.0,"lb" : -1.0,"rt" : -1.0,"rw" : -1.0]
    var avgTimesCrossedDefensesAuto = ["pc" : -1.0,"cdf" : -1.0,"mt" :  -1.0,"rp" : -1.0,"sp" : -1.0,"db" : -1.0,"lb" : -1.0,"rt" : -1.0]
    var avgTimesCrossedDefensesTele = ["pc" : -1.0,"cdf" : -1.0,"mt" :  -1.0,"rp" : -1.0,"sp" : -1.0,"db" : -1.0,"lb" : -1.0,"rt" : -1.0]
    var siegePower = -1.0
    var siegeConsistency = -1.0
    var siegeAbility = -1.0
    var numRPs = -1
    var numAutoPoints = -1
    var numScaleAndChallangePoints = -1
}

class Team {
    var name = "noName"
    var number = -1
    var matches : [Match] = []
    var teamInMatchDatas : [TeamInMatchData] = []
    var calculatedData : CalculatedTeamData = CalculatedTeamData()
}

class Match {
    var number = -1
    var calculatedData = CalculatedMatchData()
    var redAllianceTeamNumbers = []
    var blueAllianceTeamNumbers = []
    var redScore = -1
    var blueScore = -1
    var redDefensePositions = ["", "", "", ""]
    var blueDefensePositions = ["", "", "", ""]
    var redAllianceDidCapture = false
    var blueAllianceDidCapture = false
}

class CalculatedMatchData {
    var predictedRedScore = -1.0
    var predictedBlueScore = -1.0
    var numDefenseCrossesByBlue = -1
    var numDefenseCrossesByRed = -1
    var blueRPs = -1
    var redRPs = -1
}

class TeamInMatchData {
    var teamNumber = -1
    var matchNumber = -1
    
    var didGetIncapacitated = false
    var didGetDisabled = false
    
    var rankDefenseCrossingEffectiveness = ["pc" : -1,"cdf" : -1,"mt":  -1,"rp" : -1,"sp" : -1,"db" : -1,"lb" : -1,"rt" : -1,"rw" : -1]
    var rankTorque = -1
    var rankSpeed = -1
    var rankEvasion = -1
    var rankDefense = -1
    var rankBallControl = -1
    
    //Auto
    var ballsIntakedAuto = [-1, -1, -1, -1, -1, -1]
    var numBallsKnockedOffMidlineAuto = -1
    var timesDefensesCrossedAuto = ["pc" : -1,"cdf" : -1,"mt" : -1,"rp" : -1,"sp" : -1,"db" : -1,"lb" : -1,"rt" : -1,"rw" : -1]
    var numHighShotsMadeAuto = -1
    var numLowShotsMadeAuto = -1
    var numHighShotsMissedAuto = -1
    var numLowShotsMissedAuto = -1
    var didReachAuto = false
    
    //Tele
    var numHighShotsMadeTele = -1
    var numLowShotsMadeTele = -1
    var numHighShotsMissedTele = -1
    var numLowShotsMissedTele = -1
    var numGroundIntakesTele = -1
    var numShotsBlockedTele = -1
    var didScaleTele = false
    var didChallengeTele = false
    var timesDefensesCrossedTele = ["pc" : -1,"cdf" : -1,"mt" :  -1,"rp" : -1,"sp" : -1,"db" : -1,"lb" : -1,"rw" : -1
]
}
