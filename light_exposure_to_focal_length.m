
%% light_exposure_to_focal_length

function [focal_length] = light_exposure_to_focal_length(flux, exposure_time)

%% Context: 
% Inspired by a paper by Ziolkowski et al.: https://doi.org/10.1039/C3SM51386F
% A poly-NIPAM-co-spiropyran hydrogel, which can be treated as a lens, 
% shrinks upon exposure to light. This changes its focal length for two
% reasons:
% 1) The refractive index of the gel increases.
% 2) The curvature of the top and bottom of the gel increase.

%% Purpose: 
% Given previous data on luminous flux and light exposure time vs. size,
% and given an arbitrary flux and exposure time, estimate the focal length
% of the 3mm-diameter gel after it contracts.

%% Parameters:
% inputs:
% 
% flux = the luminous flux used in the experiment, in lumens. 
% acceptable range: 100 to 5000 (inclusive)
% 
% exposure_time = the time for which the gel was subject to the light, in
% seconds
% acceptable range: 60 to 3000 (inclusive)
% 
% Note that the function diverges very suddenly and rapidly with small
% inputs, so inputting two very small numbers in the acceptable ranges may
% still result in NaN (infinity).
% 
% output:
% 
% focal_length = the focal length of the gel acting as a lens, in
% millimeters

%% Process:
% 1) Take a previously acquired set of data of luminous flux and exposure
% time as independent variables and gel size as the dependent variable. 
% (Here, the data was fabricated).
% 2) Find a two-dimensional function that interpolates the data.
% 3) With the given values of flux and exposure time, find the size that
% the gel would theoretically contract to.
% 4) Using a model of how the gel size relates to its lens radius (and by
% extension, its focal point), find the focal point yielded at the given
% gel size. This model was devised separately with pen, paper, and the
% computational engine Wolfram-Alpha. See %% Function Limitations.

%% Function Limitations:
% For now, this function serves as an exercise for estimating the focal
% length of the gel. In it's current state, it will be inaccurate for
% the following reasons:
% 1) It does not account for the change in the refractive index of the gel
% since it is unknown to what extent the refractive index changes.
% 2) It does not account for both surfaces curving since the top surface
% will curve more, but by an unknown amount. Thus, the function will only 
% account for the curvature of the top of the gel.
% 3) It does not account for the fact that the volume of the gel will
% decrease as it contracts. On the contrary, the gel as it is modeled in
% this function will actually grow in volume as it contracts. Fortunately,
% this error is not very significant as long as the extent of the
% contraction is reasonably small.
% 4) It does not account for the wavelength of the incident light affecting
% the focal length.

%% Previous Data
% Fabricated data of flux and exposure time vs. gel size
% Flux data, in lumens
flux_data = [100, 500, 1000, 5000];
% Exposure time data, in seconds
exposure_time_data = [60, 300, 600, 3000];
% Gel size at each flux:exposure_time pair
gel_size_data = [2.99, 2.97, 2.94, 2.90;
                    2.96, 2.93, 2.90, 2.86;
                    2.93, 2.89, 2.86, 2.82;
                    2.88, 2.82, 2.79, 2.75];

% Uncomment the below line of code to see a visualization of the data
% (rotate the mesh since it begins at an inconvenient viewing angle)

% mesh(flux_data, exposure_time_data, gel_size_data);                

%% Interpolating Function
% Find a function that interpolates the data, and find where the input data
% points lie on the function
gel_size = interp2(flux_data, exposure_time_data, gel_size_data, flux, exposure_time);

%% Lens Radius
% The lens can be modeled as a fraction of a circle where:
% 1) The arc length is equal to the diameter of the gel's initial state
% before contraction
% 2) The distance between the two ends of the arc is gel_size, which was
% calculated in the previous step
% 3) The radius, r, is the unknown quantity
% The relationship between gel_size and r can be derived using the Sine
% Law. Then, for greater computational speed, the relationship was
% approximated using a Taylor Series expansion.

% The relationship between the gel size and the lens radius, given a gel
% that is intially 3 millimeters in diameter, is as follows:

gel_size_model = @(r) ( - ( gel_size ) + 32 * ( 243 - 540 * r^2 + 360 * r^4 ) / ...
    ( r^3 * ( ( pi - ( 3 / r ) )^4 - 80 * ( pi - ( 3 / r ) )^2 + 1920 ) * (pi * r - 3 ) ) );

% r (i.e. radius) is a function of gel_size, where gel_size can be isolated 
% but r cannot be. gel_size is isolated and moved to the other side of the
% equation such that the equation equals zero. This is in order to use
% fzero to solve the equation, which is faster than fsolve.
% The "zero" side of the equation is set to the arbitrary variable
% "gel_size_model".

% In theory, there are two roots of the function given any positive value
% of gel_size, both the same in magnitude, but opposite in sign. Thus, the 
% starting value for fzero is set to be a positive number so that it finds
% the positive root. Since the radius must be greater than the arc length
% divided by pi, it makes sense to choose a starting value greater than
% that (10 was chosen arbitrarily). The resulting values agree with the
% graphing calculator Desmos modeling the same function.
radius = fzero(gel_size_model, 10);

% Assuming the bottom of the gel remains flat, and only the top surface
% of the gel curves, the focal_length is equal to the radius of the
% circle defined by the curvature of the top surface.
focal_length = radius;

end

