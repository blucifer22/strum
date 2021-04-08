import csv
path = "c:/Users/caryp/Desktop/Important Shit/ECE350/Final Project/strum/strum/"

with open(path + "colors.csv", "r") as csvFile:
       with open(path + "colors.mem", "w") as memFile:
            for row in csv.reader(csvFile):
                memFile.write(" ".join(row) + "\n")

with open(path + "image.csv", "r") as csvFile:
    with open(path + "image.mem", "w") as memFile:
        for row in csv.reader(csvFile):
            memFile.write(" ".join(row) + "\n")

with open(path + "Overlay.csv", "r") as csvFile:
    with open(path + "Overlay.mem", "w") as memFile:
        for row in csv.reader(csvFile):
            memFile.write(" ".join(row) + "\n")
