# The Cognitive Benefits of Embodied Learning for Early Literacy Education. 

Raw BIDS data: https://openneuro.org/datasets/ds004017 

OSF repository with individual data derivatives: https://osf.io/2bhx3/ 
  
Project preprint:  

---

### Design Summary:  
#### **Participants:**
21 children aged between 6 and 8 years old who attended school grades 0 and 1 in Denmark.
Participants were randomly assigned to one of two groups - a motor intervention or control group.

Participant information regarding group allocation is stored in the subjects.xlsx file. 

#### **Procedure:**
Participants completed the procedure in three parts. Responses on the keyboard.

- Before/Pre/Baseline: A two-alternative forced choice discrimination task including letters "b" and "d"

- Intervention or Control Session: A simple visual search task including a target letter (either b or d) and three distractor letters chosen at random (p or q). Participants in the intervention group completed this task using letter-related movements and made responses on a touch screen. Participants in the control group made responses with the help of an eye tracker and did not make any letter-related movements.

- After/Post: A two-alternative forced choice discrimination task including letters "b" and "d". Responses on the keyboard.

In this report we were only interested in the differences in brian activity during the intervention and control sessions. Therefore, we analysed the "before intervention" files to check whether there were any significant differences in the groups' activity at the baseline (i.e. prior to intervention). We also analysed the intervention data. We did not analyse the "after intervention files".
  
---

### **Scripts**  
The main script folder contains scripts that were used to analyse the intervention data. There is also a "Baseline" sub-folder which was holds scripts used to analyse the pre-intervention data.  
The scripts are numbered chronologically to reflect the different steps of analyses. s01 to s03 are pre-processing scripts operating on individual data. s04 averages individual data and saves averaged data for statistical analyses. s05 and s06 are statistical analyses scripts.  
One additional script "trials_and_channels" was used to calculate how many trials were removed at different stages of pre-processing and how many channels were interpolated per participant.
  
### **Results**  
The derivatives from preprocessing individual data files can be found in the OSF repository: https://osf.io/2bhx3/   
  
The results folder in this repository contains averaged data for each participant arranged in group level matrices. These matrices were used for plotting and for running statistical analyses. Results were arranged in separate folders for the intervention and baseline data.   
Statistics results are in the "Stats" folder. 
Quality assessment was conducted as part of data pre-processing - s03 script. It involved visual inspection of averaged data for each participant. The figures used for this are saved in the "Qual_Figs" folder. 

### **Plots**
s04 Contains the code used to produce the plots reported in the paper. Data used for plotting can be found in the Results folder (in specific sbfolders for Intervention or Baseline).
