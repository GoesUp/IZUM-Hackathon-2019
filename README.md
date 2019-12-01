# Kodko (IZUM Hackathon 2019)
My Flutter application for IZUM Hackathon 2019 used for library stocktaking

## Description
Kodko was developed during the IZUM Hackathon in Maribor on November 31, 2019.
Its primary purpuse is supposedly to help librarians dusing stocktaking.

## Usage
This following procedure needs to be followed to use the application correctly:
1. Press the *Start* button - this calls the `/start` endpoint on IZUM's server
2. Press *Novo skeniranje* to open the barcode scanner activity
3. Align the barcode with the marked area in the of the screen - the barcode should be recognized automatically and shown on the main screen
4. Repeat step 3 for as long as you'd like - each barcode is automatically sent to the `/scan/{barcode}` endpoint on IZUM's server
5. Press the *Stop* button - this calls the `/stop` endpoint on IZUM's server
