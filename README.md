# <img src="https://user-images.githubusercontent.com/35761701/204182243-6ad37686-e613-4280-ba83-7ec10bd25968.png" width="256" />
<img align="right" src="https://user-images.githubusercontent.com/35761701/204183771-ee8c8094-3977-4aaa-9e4a-011624c6abd7.png" width="400" />

MusicBar is an easy, lightweight way to see currently playing music when working!

* Visualize Now Playing Songs
* Supports every Application
* Launch At Login Capability

## Installation

### **Download it on the App Store today!**

<a href="https://musicbar.inedible.dev">![Download it on the App Store today!](https://user-images.githubusercontent.com/35761701/230629585-83686d04-dc60-4e97-8de0-d1d4ebb7a023.svg)</a>

or

Download [MusicBar.app.zip](https://github.com/Kentakoong/MusicBar/releases/download/v0.1.1/MusicBar.app.zip) from the [Releases](https://github.com/Kentakoong/MusicBar/releases) page. 

<img width="512" alt="Screenshot 2022-11-18 at 3 28 39 PM" src="https://user-images.githubusercontent.com/35761701/202656533-3b1be2f7-14ec-44c2-9d52-cf9cb0165653.png">

Then, if needed, extract the zip file.

Lastly, drag the Application to the /Applications folder and open your Launchpad to run it!

<img width="512" alt="Screenshot 2022-11-18 at 3 31 01 PM" src="https://user-images.githubusercontent.com/35761701/202657110-3d0f44c2-77df-4526-b3ee-6816978d2e2a.png">

## Building the Application

  Check out [BUILD.md](https://github.com/Kentakoong/MusicBar/blob/main/BUILD.md) to build the Application yourself!

## Can't open the Application?

  For now, code signing is still broken. To make it work, run these command
  
  ```console
  $ xattr -d com.apple.quarantine <your_path_to_folder>/MusicBar.app
  
  #then 
 
  $ sudo codesign -f -s - <your_path_to_folder>/MusicBar.app
  ```
  Thank you [@mintyleaf](https://github.com/mintyleaf) for the workaround!

  Please check [#6](https://github.com/Kentakoong/MusicBar/discussions/6) for further details!
