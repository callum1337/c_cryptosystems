cryptocfg = {}

cryptocfg.coords = {x,y,z}
cryptocfg.enter = {x,y,z}
cryptocfg.exit = {x,y,z}
cryptocfg.systems = {
    {id = 1, name = "Starter Miner",  gpu = '1050-TI', cpu = 'Intel i5-3570', amountPerMin = 0.000005, stringedFormat = '0.000005', price = 50000},
    {id = 2, name = "Bitcoin Miner 1",  gpu = '1060', cpu = 'AMD Ryzen 5 3600X', amountPerMin = 0.000015, stringedFormat = '0.000015', price = 100000},
    {id = 3, name = "Bitcoin Miner 2",  gpu = '1080', cpu = 'AMD Ryzen 7 3700X', amountPerMin = 0.000025, stringedFormat = '0.000025', price = 250000},
    {id = 4, name = "Bitcoin Miner 3", gpu = '2060', cpu = 'AMD Ryzen 9 3900X', amountPerMin = 0.000035, stringedFormat = '0.000035', price = 500000}
}

return cryptocfg
