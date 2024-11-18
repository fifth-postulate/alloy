module edentifier

enum State { Ready, PinVerified, WaitForConfirmation }
enum Event { HumanEnterPin, HumanPressOk, PcDisplayData, PcGenCryptogram }
enum Output { Ok, Error, Timeout, Cryptogram }

one sig Edentifier {
  var state: State,
  var event: Event,
  var output: Output,
}

fun transitions: set State -> Event -> State -> Output {
   Ready -> PcDisplayData -> Ready -> Error
+ Ready -> PcGenCryptogram -> Ready -> Error
+ Ready -> HumanPressOk -> Ready -> Timeout
+ Ready -> HumanEnterPin -> PinVerified -> Ok
+ PinVerified -> PcDisplayData -> WaitForConfirmation -> Ok
+ PinVerified -> HumanEnterPin -> PinVerified -> Ok
+ PinVerified -> HumanPressOk -> PinVerified -> Timeout
+ PinVerified -> PcGenCryptogram -> Ready -> Cryptogram
+ WaitForConfirmation -> HumanEnterPin -> PinVerified -> Ok
+ WaitForConfirmation -> HumanPressOk -> PinVerified -> Ok
+ WaitForConfirmation -> PcDisplayData -> WaitForConfirmation -> Error
+ WaitForConfirmation -> PcGenCryptogram-> WaitForConfirmation -> Error
}

check TransitionsTableIsComplete {
  all s: State, e: Event | some transitions[s][e]
}

pred init {
  Edentifier.state = Ready
}

pred step {
  Edentifier.state' = transitions.univ[Edentifier.state][Edentifier.event]
  Edentifier.output = transitions[Edentifier.state][Edentifier.event][univ]
}

pred runStateMachine {
  init
  always step
}

run {
  runStateMachine
  eventually { Edentifier.output = Cryptogram }
} 

check {
  runStateMachine => {
    always { Edentifier.output = Cryptogram => once Edentifier.event = HumanPressOk }
  }
}
