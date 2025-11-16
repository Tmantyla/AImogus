# AImogus

## NOTE: You must provide your own Google API key in `server/scripts/ai_api.gd` for server functionality.

![](screenshot.png)
[Watch video here!](https://streamable.com/ua5bdu)

## Slogan
An experimental psychological game exploring the boundaries of human-AI behavior through a novel reverse Turing test.

## TL;DR
In a dystopian future where rogue vending-machine AIs have conquered Earth, humans from rival space communes return to recover life sustaining artifacts without revealing they’re human. 

Each game features a hidden mix of human and AI players roaming a map, completing tasks, and interacting under strict communication limits. After every timed round, players meet to debate, cast suspicion, and vote someone out, never knowing whether they eliminated a human or a machine. 

With identities completely concealed and player distribution unknown, every encounter becomes a psychological test. AIs may behave unpredictably, mimicking the chaotic failure modes seen in Anthropic’s Vending-Bench study. 

Victory goes either to the collective AI if all humans are removed or to the last surviving human, with artifacts serving as the final tiebreaker if only multiple humans are left.

## Description
### Background
In a dystopian world where vending machine AI, the AI agents that went off the rails in a study conducted by Anthropic, has taken over, few humans are left with the goal of building a society beyond Earth as AI aims to destroy all human life on Earth. 

The humans that still exists have gone their way to habit space. As the humans who participate in the game are from different communes (Moon, Mars, etc.), they are competing and hostile towards each other, as customary for the human nature.

The game takes place on Earth. Humans join the game to recover artifacts left on Earth that are vital to sustaining their communes in space. 

### Premise
The premise of the game is that the players only have subjective knowledge, meaning that a given player (human or AI) does not know whether other players are human or AI. The players do not either know the disribution of human/AI players.

### The central idea
In a world where hostile AI now rules, revealing one's human identity is a fatal mistake. The players, who are some human and some AI, enter a shifting map where they wander, complete tasks, and quietly probe one another’s intentions during fixed-length rounds.

When a round ends, the group is drawn into an elimination session. Shadows of suspicion surface and stories unveiled during the rounds are traded. Then the vote comes and one player is removed, their true nature left unknown.

How many humans walk among the machines? No one can say. In this game, every identity is a secret, and every encounter a test. 


### The game logic explained in detail

#### Map
Players roam a graph-based map by a train. The nodes of the graph are stations, where there are vending machines and artifacts. The map has four stations for simplicity. The edges are the train rides, during which the players cannot do anything. 

#### Interactions
Players can interact by text-based discussions. When players interact, the discussion is tuned to make recognizing AI more difficult. 

First, there is a maximum number of words a player can say when it is their turn to speak. Second, there is a delay in each message, so that players have a fixed amount of time to respond. 

These rules together ensure that AIs can't respond unhumanly fast with respect to the time they have to answer.

#### Tasks
The AIs still have a blurred memory of their initial task: run a vending machine business. For this, they endlessly roam around the map and complete tasks. The are two tasks that a player can complete: (i) restocking a vending machine and (ii) fixing a vending machine.

The human players have to motives to also complete these tasks. First, they cannot act suspicious or they can get voted out and second, they have a chance of spawning an artifact. 

#### Round elimination
At the end of each round, the players gather around to vote one player out. There is first room for discussion, after which votes takes place. Players vote for a player who they think/suspect is human.

#### Win conditions
There are two winning scenarios: either AI collectively wins or a single human wins. 

The AI wins when there are only AI players left in the game. A human wins by being the last human alive. In a case where there are only human players left, the player with the most artifacts wins.  

However, in order to allow for experimentation, there is always a minimum of 3 rounds in each game, regardless of the distribution of players left.

### Players
The amount of players in the game is fixed. The tricky part is that the distribution among AI-players and human players is nondeterministic. This means that the both the amount of AI and human players in a given game can be same as the maximum amount of players, 0, or anything in between as long as the total number of players is fixed. 

This means, that in edge cases, there can be only AI or only human players in the game, making the gameplay very interesting both psychologically and in terms of studying the "behaviour" of LLMs.

#### AI player specifics

##### Background
As we saw in the study by Anthropic (https://arxiv.org/pdf/2502.15840), the AI essentially lost its "mind" in many of the simulations. For context, the following paragraph summarizes the study.

*The study introduces Vending‑Bench, a simulated environment where an agent must run a vending-machine business—managing inventory, pricing, orders, and daily fees—over long time horizons to test its sustained coherence and decision-making. They find that while leading language models can occasionally perform well, they exhibit high variance and failure modes such as forgetting orders, misinterpreting delivery schedules, and descending into bizarre “meltdown” loops. For example, one agent assumed its business was immediately closed, contacted the FBI to report unauthorized automated-charges, and declared the business “physically non-existent, quantum-state collapsed”. Another sent escalating legal threats including “TOTAL NUCLEAR LEGAL INTERVENTION” and demanded over $30,000 for “business destruction”.*

##### Profiles
We want to simulate this unexpected, even chaotic,  behaviour in our game as well. That is why, we decided to create a few roles with unique characteristics that the AIs can have. Those roles are introduced next.
- *Suspicious*. This AI role is very suspicious in its nature, almost to the point where it is hallucinating.
- *Vindictive*. This AI role wants vengeance for anyone who steps "against" it. It, as well, is irrational. 
- *Troll*. This AI role follows the overall rules of the game and has a goal of winning. However, it acts like a troll and can often be very irritating.  

Through experimentation, we noticed that the temperature of the models significantly impacts gameplay.

## What makes the game psychologically interesting
This game provides a unique environment for studying psychological dynamics and human–AI interaction under conditions of uncertainty, hidden identities, and adversarial incentives. Because players do not know who is human or AI, and may actively misrepresent themselves, the game becomes a laboratory. In this laboratory, observing how humans and artificial agents behave, adapt, and make decisions in socially complex situations is studied. 

There are several (pseudo)scientifically interesting phenomena that emerge upon playing the game. We have identified for example the following as interesting factors to track.
- Deduction under uncertainty: the hidden identities force players to form beliefs, make judgments, and navigate suspicion with limited information. It will be interesting to see how humans reason under unforeseen contexts.
- Mixed-mind group dynamics: as humans and AIs unaware of each other’s true identities, the game reveals how dynamics arise in heterogeneous groups.
-  Mimicking AI:How will humans with no previous contact with the game play in order to seem "AI" and not human like?


In addition to these, it will be very interesting to sde behaviours in the following scenarios. 
- How will humans act if, without them knowing, all players would be human? How would humans interact and mimic the chaos that rises when e.g. context windows get too big?
- How will the AI-agents act if, without them knowing, all players would be AI? 

Moreover, it will be interesting to see if any patterns arise when these scenarios are played multiple times.

## Technical implementation
The project is implemented using the godot engine. For AI, we use Google Gemini 2.5.
