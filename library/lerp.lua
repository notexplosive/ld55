local lerp = {}

function lerp.number(start, destination, percent)
    return (destination - start) * percent
end

return lerp
