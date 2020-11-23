# Apoleia Noise Tracker

Manage your health by tracking your diet

More details at https://devpost.com/software/noisetracker
Download the apk at https://github.com/bhscomputerscienceclub/wwphacks-2020-ohm/releases
Video demonstration: https://www.youtube.com/watch?v=Cau4sZzlv7U

By:

    @karmanyaahm
    @mooreli10423
    @jgold12
    
[Link to the Slideshow](https://docs.google.com/presentation/d/1uY0nI8e0O7Oyt7t-fotuANjd26rCTVCvsNk8ZUlibLg/edit?usp=sharing)


## Inspiration
We want to help people preserve their hearing and save money on potential treatments for hearing loss.

## What it does
Apoleia, our noise exposure tracker, tracks how much noise, in decibels, you have heard in your day. This data can tell you if you potentially lost hearing based on guidelines from the Occupational Safety and Heath Administration.

## How we built it
We used Flutter and the Android Application API to build something that monitors background noise.

## Challenges we ran into
The primary challenge was being able to run the app in the background without it getting killed by the operating system. We overcame this challenge by using Android's Foreground Service API.

## What we learned
We learned skills like streams in Dart and running platform native code in Flutter.

## What's next for Apoleia 

We hope to build a model that can store your data for more than a month or year and show you your average and maximum decibel per day and hour. Additionally, recording data about when and where noise exposure happened can help the user make decisions about their life to improve their health. We will use this data to show you if you have had potential hearing loss and tell you what to do to avoid hearing loss in the future.

    
![Demo app screenshot](/demo/screenshot1.png)
![Demo notification screenshot](/demo/screenshot2.png)
