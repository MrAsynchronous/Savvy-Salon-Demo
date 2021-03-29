-- TutorialConfig
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    
    Dialog = {
        {
            Text = "Welcome to the Savvy Salon Demo! My name is Natasha and I'm going to be teaching you how to play and create your very own salon empire! Let's get started, follow me!",
            Animation = "rbxassetid://507770239",
        },
        {
            Text = "Right now we're inside of your salon, eventually you can customize it to look exactly how you want, from painting the walls, to changing the floors, the sky is the limit!",
            Animation = "rbxassetid://2510196951"
        },
        {
            Text = "Oh no..! We're not ready but we already have our first customer! Quickly, lets get this salon ready to serve!",
            Animation = "rbxassetid://6582044994",
            Face = "rbxassetid://147144198"
        },
        {
            Text = "Alrighty so we need to place down the key components of the salon, first lets open up your inventory!",
        },
        {
            Text = "Awesome! Now, let's place the desk for the secretary team so the customer can check in for their appointment! This one is free, you can always buy more at the shop!",
            ItemName = "SecretaryDesk"
        },
        {
            Text = "Great! Looks like you're getting the hang of this really quickly, you'll be on your own soon! Now, place the waiting chair located in your inventory so the customer have a place to sit!",
            ItemName = "WaitingChair"
        },
        {
            Text = "Incredible job! Now place down the hair washing station so customers can get their hair washed before their cut!",
            ItemName = "ShampooStation"
        },
        {
            Text = "Wow, you're really good at this! Now the service stations need to be placed down so the customer can get their dream hairstyle! Go ahead and place those items located in your inventory. ",
            ItemName = "CuttingStation"
        },
        {
            Text = "Looks like you're ready to grow your empire! (other information would be here post-demo in regards to going to the shop, hiring employee's, etc)"
        }
    }

})