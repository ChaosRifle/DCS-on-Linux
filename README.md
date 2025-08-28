# DCS-on-Linux
- a set of tools, known issues (and workarounds), as well as other locations to get the best, up to date, advice for running dcs on linux, in an attempt to defragment the whole experience
- **If you have any questions this repo did not explain or link to a source on, *please*, open an issue / go to the matrix server and ping(@) a contributer, and *ask the question while also noting that the repo did not explain it!*** 
- If you had a problem, please report it! you are helping others by doing so, somebody else probably had the same issue too. Thank you!




# INSTALLING AND TROUBLESHOOTING
please [follow along with our wiki / guides](https://github.com/ChaosRifle/DCS-on-Linux/wiki), and select an installation method. DCS has many issues and the guides are there to mitigate the current known issues, both with DCS, and the installation method itself sometimes. This link also provides troubleshooting pages.



# CONTRIBUTING
This is meant to be a community hub (and eventually wiki) for the current best ways and tools to use to install DCS on linux - as such, when new information comes to light, ***please let a maintainer know, or make a PR to the repo***. If the lutris installer needs an update, please make a PR to the yaml script contained here or ping Chaos, as I(chaos) will use this yaml to edit and maintain the current script on lutris.net (``DoL Community Choice (Latest)``)
### guidelines
- Language/writing style: Writing should be clear, simple, in english, and ideally only able to be interpreted in a single way. Content should be kept easy to read, and as short as possible without loosing the purpose of the text. The goal of your text should be a clean, quick, and easy to understand/read solution to installing dcs and it's supporting software.
- Linking: mentions of locations on the wiki should always link to said location. Usage of terminology or abreviations should follow wikipedia standards of the first occurance linking to the relevent terminology page, on a per-section basis (ie, section of [UDEV](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)). When in doubt, link.
- ``Troubleshooting`` sections: Aims to be comprehensive of all possible issues and their fixes. Format of all problems/workarounds will be encased in a note block. These are clear, defined ``Problem`` & ``Solution`` pairs (if a solution is unknown, denote such). Optionally, and preferably, also includes cause for the problem if known. (ie, opentrack cant hook extra steam libraries, cause being opentrack only searches for the default steam library and no others) All notes must be date-stamped for the day that became an issue (yyyy/mm/dd). Old problems will be grandfathered in under ``date unknown`` date-stamps due to the work involved. expect any submissions for problems that became an issue for users in 2025+ to request a valid datestamp. All known issues and workarounds should be in this area so it can be used for stand-alone troubleshooting as if the ``Installation`` section did not exist. Old, no longer relevant, problems (ie, resolved by ED, wine, etc) will be moved to the [Troubleshooting Archive](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting-Archive) to retain records of it. 
- ``Installation`` sections: these are for step by step get-it-working-for-most-users instructions, meant to be modular for a users install case. If different instructions exist for different install methods (lutris, wine, steam, SA on steam) then your section should be segmented out as such. You may choose to mark the alternate segments as incomplete for methods you are not familliar with (done with ``> [!note] \n> this segment is incomplete``). Try to keep troubleshooting to the troubleshooting wiki, however some discretion exists for what is valid for the installation sections. Ideally for such cases it should also be in the troubleshooting section for people not following the guides to find. an example of this is the apache font problem mentioned in [fixer-scripts](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#fixer-scripts) and the [corrosponding troubleshooting page](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-slotting-into-ah-64d-apache-crashes-game) it links to). Universal issues with the game are accepted and expected, and specific edge cases for hardware or software should be scrutinized (though not nessisarilly rejected). Generally speaking, these are *instructions to be followed*, not tips & tricks or troubleshooting. 



# CREDIT
This guide very much stands on the backs of giants, without the people listed below, or the contributors on the right panel, this guide would not be anything close to what it is.

- [TheZoq2](https://github.com/TheZoq2) - original dcs on linux guide, maker of the matrix channel, and important collaboration on the proton issues page for dcs from bug reports to custom scripts to fix bugs. [ information, community ambassador, reporting, solutions ]
- [Deleterium](https://github.com/deleterium) - revamp of TheZoq2's guide that carried it forward [ information ]
- [Budderpard](https://github.com/budderpard) - the modern dcs on linux guide post 2.9 [ information ]
- onno - maintaining the hoggit wiki page [ information ]
- the countless contributors on the [proton issue](https://github.com/ValveSoftware/Proton/issues/1722) - thank you to everyone for their work there! [ information, reporting, solutions ]
- [Chaos](https://github.com/ChaosRifle) - collecting and collating data for the initial creation of this guide, initial lutris yaml, and one of the maintainers of this guide [ information, reporting, scripts ]
