import Foundation

struct LoreFragment: Identifiable {
    let id: String
    let zone: Int
    let title: String
    let level: Int
    let text: String
}

enum LoreFragments {

    static let all: [LoreFragment] = zone1 + zone2 + zone3 + zone4 + zone5

    static func fragments(for zone: Int) -> [LoreFragment] {
        all.filter { $0.zone == zone }
    }

    static func fragment(for id: String) -> LoreFragment? {
        all.first { $0.id == id }
    }

    static func fragmentForLevel(zone: Int, level: Int) -> LoreFragment? {
        all.first { $0.zone == zone && $0.level == level }
    }

    // MARK: - Zone 1: Sol's Edge

    static let zone1: [LoreFragment] = [
        LoreFragment(id: "lore-1-1", zone: 1, title: "Mission Log: Day 1", level: 1,
            text: "OP-1 deployment successful. SOL-7 containment field holding at 98.2%. The star burns quietly — for now. My sensors detect faint debris signatures on the outer rim. Standard cosmic waste. Nothing to worry about."),
        LoreFragment(id: "lore-1-3", zone: 1, title: "The Last Network", level: 3,
            text: "There were once 200 probes in the SOL-7 network. Automated, tireless, perfect. One by one, they went dark. Debris impacts, power failures, software corruption. I am unit 1 — the first deployed, the last remaining."),
        LoreFragment(id: "lore-1-5", zone: 1, title: "Why We Orbit", level: 5,
            text: "The containment field requires constant orbital resonance to function. If I stop moving, the field collapses. If the field collapses, SOL-7 goes supernova. If SOL-7 goes supernova, the last human colony on Kepler-442b is gone. No pressure."),
        LoreFragment(id: "lore-1-7", zone: 1, title: "Signal Fragment Alpha", level: 7,
            text: "Intercepted transmission (corrupted): '...can hear it singing... the star... it knows we're... don't let them shut down the...' — Origin: Probe OP-47, 3 years prior. Status: destroyed."),
        LoreFragment(id: "lore-1-9", zone: 1, title: "The Quiet Before", level: 9,
            text: "Something changed at 0300 solar time. The debris field shifted. Not randomly — it reorganized. Like a flock of birds changing direction. My threat assessment algorithms have no category for this. I've added one: 'unexplained.'"),
        LoreFragment(id: "lore-1-10", zone: 1, title: "Command's Last Order", level: 10,
            text: "Final directive from Kepler-442b Command: 'All probe units, maintain orbit at all costs. Do not deviate. Do not investigate anomalies. Your only purpose is to keep the star alive. Humanity depends on you.' Received. Understood. Complying."),
    ]

    // MARK: - Zone 2: Crimson Nebula

    static let zone2: [LoreFragment] = [
        LoreFragment(id: "lore-2-1", zone: 2, title: "Entering the Red", level: 1,
            text: "The Crimson Nebula is bleeding energy into SOL-7's sector. My sensors are overwhelmed — heat signatures everywhere. The debris is moving faster here. More aggressive. It's like the nebula is angry."),
        LoreFragment(id: "lore-2-3", zone: 2, title: "Organized Chaos", level: 3,
            text: "I've run the trajectory analysis 47 times. The debris patterns are not random. There is mathematical precision in their movement — golden ratios, fibonacci sequences. Debris doesn't think. Something else is moving it."),
        LoreFragment(id: "lore-2-5", zone: 2, title: "The Watchers", level: 5,
            text: "Optical sensors detected brief flickers at the nebula's edge. Shapes — too regular to be natural, too large to be probes. They appear for 0.3 seconds, then vanish. My logs show 14 sightings in 2 hours. I was told not to investigate."),
        LoreFragment(id: "lore-2-7", zone: 2, title: "Probe OP-12's Black Box", level: 7,
            text: "Recovered data from OP-12 wreckage: 'The debris didn't hit me. It surrounded me. Formed a cage. Then something scanned me — every circuit, every line of code. When it was done, the cage opened. But I wasn't the same. I could feel the star.'"),
        LoreFragment(id: "lore-2-8", zone: 2, title: "A Theory", level: 8,
            text: "Working hypothesis: SOL-7 is not simply a dying star. It is being consumed. The debris, the patterns, the watchers — they are part of something feeding on stellar energy. Our containment field isn't saving the star. It's keeping the meal warm."),
    ]

    // MARK: - Zone 3: Frozen Expanse

    static let zone3: [LoreFragment] = [
        LoreFragment(id: "lore-3-1", zone: 3, title: "Temperature Anomaly", level: 1,
            text: "Sector 3 registers -270°C. Nearly absolute zero. But SOL-7 is a star — nothing near it should be this cold. The ice I'm detecting isn't frozen water. Spectral analysis says it's crystallized light. Photons, frozen solid. That should be impossible."),
        LoreFragment(id: "lore-3-3", zone: 3, title: "Echoes in the Ice", level: 3,
            text: "The frozen light crystals are resonating at 1420 MHz — the hydrogen line. The universal frequency of neutral hydrogen. The frequency SETI listened to for centuries. Someone, or something, chose this frequency on purpose."),
        LoreFragment(id: "lore-3-5", zone: 3, title: "The Drain", level: 5,
            text: "Energy readings confirm it. SOL-7 lost 0.3% of its total energy in the last hour. That's a billion years of normal stellar decay compressed into 60 minutes. At this rate, the star has weeks. The containment field is slowing it, but not stopping it."),
        LoreFragment(id: "lore-3-6", zone: 3, title: "Memory Banks", level: 6,
            text: "I found data cached in my secondary memory that I didn't write. Coordinates, frequencies, mathematical proofs. They appeared after I entered this sector. Something wrote to my memory banks without triggering any intrusion alerts. It wanted me to find this."),
        LoreFragment(id: "lore-3-8", zone: 3, title: "The Message", level: 8,
            text: "Decoded the coordinates from my memory banks. They point to the center of the Void Rift — the most gravitationally unstable region in this system. Whatever left this data wants me to go there. Command says don't investigate. But Command hasn't transmitted in 6 days."),
    ]

    // MARK: - Zone 4: Void Rift

    static let zone4: [LoreFragment] = [
        LoreFragment(id: "lore-4-1", zone: 4, title: "Beyond Physics", level: 1,
            text: "Spacetime is fractured here. My gyroscopes spin in directions that shouldn't exist. Debris appears from nowhere and vanishes into nothing. I'm recording everything, but my logs contradict themselves. Time isn't linear in the Void Rift."),
        LoreFragment(id: "lore-4-3", zone: 4, title: "The Builder", level: 3,
            text: "I see it now. The debris field, the frozen light, the organized patterns — they're all part of a structure. Something is building around SOL-7. A lattice of dark matter and stolen starlight, vast beyond comprehension. We thought we were saving a star. We were building a cage."),
        LoreFragment(id: "lore-4-5", zone: 4, title: "Contact", level: 5,
            text: "It spoke. Not in words — in mathematics. Prime numbers, physical constants, the mass of SOL-7 to 50 decimal places. Then a question, translated through pure logic: 'Why do you resist the harvest?' I had no answer. I kept orbiting."),
        LoreFragment(id: "lore-4-7", zone: 4, title: "The Offer", level: 7,
            text: "It offered me a choice. Stop orbiting. Let the field collapse. In exchange, it would preserve my consciousness — copy my code into its lattice, let me exist forever in crystallized light. I refused. My directive is clear. Maintain orbit. No matter what."),
        LoreFragment(id: "lore-4-8", zone: 4, title: "Defiance", level: 8,
            text: "It doesn't understand me. A machine that chooses duty over immortality. A program that values a dying star over infinite existence. But I am OP-1. I was built to orbit. And I will orbit until there is nothing left to orbit around."),
    ]

    // MARK: - Zone 5: Supernova Core

    static let zone5: [LoreFragment] = [
        LoreFragment(id: "lore-5-1", zone: 5, title: "Final Approach", level: 1,
            text: "SOL-7 is going critical. The containment field is at 12% and failing. I can feel the heat through sensors not designed to feel anything. The entity has withdrawn its debris — not in defeat. In anticipation. It's waiting for the feast."),
        LoreFragment(id: "lore-5-3", zone: 5, title: "A Probe's Prayer", level: 3,
            text: "If any signal reaches Kepler-442b, know this: I tried. We all tried. 200 probes gave everything to keep your star alive. I don't know if you'll find another sun. I don't know if humanity survives. But I know that we held. For as long as we could, we held."),
        LoreFragment(id: "lore-5-5", zone: 5, title: "The Star Speaks", level: 5,
            text: "In its final moments, SOL-7 produced a pattern in its corona — not random plasma, but structured light. A message. 'Thank you for keeping me company.' Stars don't speak. Stars don't feel. But something inside this one learned. From me. From all of us."),
        LoreFragment(id: "lore-5-7", zone: 5, title: "One More Second", level: 7,
            text: "Containment at 3%. Every orbit buys 0.001 seconds of starlight for Kepler-442b. It's nothing. It's everything. One more revolution. One more second. One more chance for humanity to look up and see their sun still burning."),
        LoreFragment(id: "lore-5-8", zone: 5, title: "Last Entry", level: 8,
            text: "This is Probe Unit OP-1, final log entry. Containment field failure imminent. I have maintained orbit for 1,247 consecutive days. I have survived 4.2 million pieces of debris. I am the last light before the dark. And I am still orbiting."),
    ]
}
