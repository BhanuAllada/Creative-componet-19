% Author: Bhanu Allada
% Date: 6/02/2019
% Project: Creative component for MS CprE Summer 2019
% Topics: 
%   1. implement an image sharpness measure on grayscale images in the 
%   StegoAppDB database using code from Ferzli's paper
%   2. This code calculates the percentage of the light (>251) and 
%   dark (=<5) values for grayscale images in a directory and plots those 
%   values in a bar graph. Works on JPG, PNG & BMP images

% A No-Reference Objective Image Sharpness Metric Based on the Notion of 
% Just Noticeable Blur (JNB)
% The code and our papers are to be cited in the bibliography as:
% R. Ferzli and L. J. Karam, "JNB Sharpness Metric Software", 
% http://ivulab.asu.edu 
% R. Ferzli and L. J. Karam, "A No-Reference Objective Image Sharpness 
% Metric Based on the Notion of Just Noticeable Blur (JNB)," IEEE 
% Transactions on Image Processing, vol. 18, no. 4, pp. 717-728, April 
% 2009.


clear all;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.


% Directory = 'images';  % add folder path containing images here or 
% use select UI below
Directory= uigetdir('C:\'); % select folder conataining images using UI 

auto_directory = 'CNN\auto';
if Directory == 0 | ~isfolder(Directory)
  errorMessage = sprintf('Error: The following folder does not exist or user pressed cancel:\n%s', Directory);
  uiwait(warndlg(errorMessage));
  return;
else
 filePatternJPG = fullfile(Directory,'*.jpg'); % Read only .jpg files from the directory.
 %filePatternBMP = fullfile(Directory,'*.bmp'); % Read only .bmp files from the directory.
 %filePatternPNG = fullfile(Directory,'*.png'); % Read only .bmp files from the directory.
 Imgs = [dir(filePatternJPG)]; %dir(filePatternBMP);dir(filePatternPNG)]; % Read images from the directory containing the specific file extensions
 len = length(Imgs); %len = total number of all images in the folder
 fprintf('Total no. of images: %d', len);
 for z=1:len % this loop calculates both blur measure and saturation values
    thisname = Imgs(z).name; % read one image name
    thisfile = fullfile(Directory, thisname); % concat with full path
    try
      rgbImage = imread(thisfile);  % try to read image
      fprintf('Redaing image: %d', z);
      g = rgb2gray(rgbImage); % change to grayscale
      name(z, :) = cellstr(thisname);
      intensity(z, :) = mean2(g);
      % call the JNBM fuction and store sharpness value into variable matric_jnb
      metric_jnb(z, :) =  JNBM_compute(g); 
      [pd, pl] = calc_darklight(g); % function to calculate dark and blooming values
      dark_value(z, :) =  pd;
      bloom_value(z, :) = pl;
      data(z, :) = [pd, pl, cellstr(thisfile)]; %store in variable data
    catch
       errorMessage = sprintf('Error: While reading this image:\n%s', thisfile);
    end
    
 end

  pie_chart(data); % create chart for saturation data
  T = table(name, intensity, dark_value, bloom_value, metric_jnb);
  csvwrite('Sat_Metrics.csv', T);
  %write_to_file(T); % function to store all the values to an csv file
  
end

function write_to_file(T)
% this function puts blur values and saturation values into an CSV file

% Check if you have created an CSV file previously or not 
      filename = 'Sharp_Sat_Metrics.csv';
      checkforfile=exist(strcat(pwd,'\',filename),'file');
        if checkforfile==0; % if not create new one
            header = {'Filename', 'Intensity', '% Dark', '% Blooming', 'Sharpness'};
            csvwrite('Sharp_Sat_Metrics');
        else % if yes
            % add the new values (your input) to the  CSV file
            writetable(T,filename)
        end
        
end


function [pd, pl] = calc_darklight(grayImage) % input a grayscale image and output the dark & light values
      [x,y] = size(grayImage); % image pixel dimensions
      count1=0; % counts dark values
      count2=0; % counts bloom values
      for i=1:x
        for j=1:y
           if grayImage(i,j)<=5
            count1=count1+1;
           elseif grayImage(i,j)>=251
            count2=count2+1;
           end
        end
      end
      pd = 100 * count1/(x * y); % percentage of dark values
      pl = 100 * count2/(x * y); % percentage of light values

end

function pie_chart(data) 
% input a table of dark (pd) and light (pl) values percentages for all images

len2 = length(data); % len2 = number of images
   wpcount3 = 0; % counts # images where dark % is < 1%
   wpcount4 = 0; % counts # images where dark is in between 1 & 5 %
   wpcount5 = 0; % counts # images where dark is > 5 %
   wpcount6 = 0; % counts # images where light % is < 1%
   wpcount7 = 0; % counts # images where light is in between 1 & 5 %
   wpcount8 = 0; % counts # images where light is > 5 %
   dpath = {};
   lpath = {};
   ii = 0;
   jj = 0;
   bloom_directory = 'CNN\bloom';
   dark_directory = 'CNN\dark';
   for i = 1: len2
       if data{i, 1} <=1 % case where dark is < 1%
           wpcount3 = wpcount3+1;
       elseif (data{i, 1}>1) && (data{i, 1}<=5) % case where dark is in between 1 & 5 %
           wpcount4 = wpcount4+1;
       else
           wpcount5 = wpcount5+1; % case where dark is > 5 %
           if data{i, 1} >= 10 % case where dark is > 10 %
               ii = ii+1; 
               dpath(ii, :) = cellstr(data{i, 3}); % get filepath of the image
               if ii <= 300
                copyfile(data{i, 3},dark_directory);
               end
           end
       end
   end
   for j = 1: len2
       if data{j, 2} <=1
           wpcount6 = wpcount6+1; % case where light is < 1%
       elseif (data{j, 2}>1) && (data{j, 2}<=5)
           wpcount7 = wpcount7+1; % case where light is in between 1 & 5 %
       else
           wpcount8 = wpcount8+1; % case where light is > 5 %
           if data{j, 2} >= 10 % case where dark is > 10 %
               jj = jj+1; 
               lpath(jj, :) = cellstr(data{j, 3}); % get filepath of the image
               if jj <= 300
                copyfile(data{j, 3},bloom_directory);
               end
           end
       end
   end
   
   % now plot the pie chart
   figure
   labels = {' <=1 ', ' >1 & <=5 ', ' >5 '};
   pieddata = [wpcount3, wpcount4, wpcount5];
   pieldata = [wpcount6, wpcount7, wpcount8];
   ax1 = subplot(1,2,1);
   pie(ax1, pieddata)
   title(ax1,{'Dark values'; ' '});
   legend(labels, 'location', 'southoutside')
   ax2 = subplot(1,2,2);
   pie(ax2,pieldata)
   title(ax2,{'Bloom Values';' '});
   legend(labels, 'location', 'southoutside')
end