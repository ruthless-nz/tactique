using Random
using GLMakie
import LinearAlgebra: norm
import Base: show

GLMakie.activate!(inline=true)












# I want to see if unit1's radius overlaps with unit2
function checkOverlap(unit1::Unit, unit2::Unit;print=false)

    d = sqrt((unit1.position[1] - unit2.position[1])^2 + (unit1.position[2] - unit2.position[2])^2)
    r₁ = unit1.InfluenceRadius
    r₂ = unit2.InfluenceRadius

    if d == 0 && r₁ == r₂ 
        if print
            println("Units ", unit1.name, " and ", unit2.name, " exactly overlap")
        end
        return "overlap"
    elseif d <= r₁ - r₂ 
        if print
            println("Units ", unit2.name, " is inside ", unit1.name,)
        end
        return "swallow"
    elseif d <= r₂ - r₁ 
        if print
            println("Units ", unit1.name, " is inside ", unit2.name,)
        end
        return "swallowed"
    elseif d < r₁ + r₂
        if print
            println("Units ", unit1.name, " and ", unit2.name, " overlap")
        end
        return "overlap"
    else 
        if print
            println("Units ", unit1.name, " and ", unit2.name, " do not overlap")
        end
        return "no overlap"
    end

end

# u1 = unit("u1")
# u2 = unit("u2")
# checkOverlap(u1,u2,print=true)



"""
finds the two sets of points where two units sphere of influence intersect.
"""
function getIntersectionPoints(unit1::Unit, unit2::Unit)

    if checkOverlap(unit1, unit2) != "overlap"
        # println("Units ", unit1.name, " and ", unit1.name, " do not overlap.")
        return 
    else

        r₁ = unit1.InfluenceRadius
        r₂ = unit2.InfluenceRadius
        x₁ = unit1.position[1]
        y₁ = unit1.position[2]

        x₂ = unit2.position[1]
        y₂ = unit2.position[2]

        R = sqrt((x₂ - x₁)^2 + (y₂ - y₁)^2)

        println("v1 = ",(r₁^2 + r₂^2)/R^2)

        # https://math.stackexchange.com/questions/256100/how-can-i-find-the-points-at-which-two-circles-intersect
        x1 = (1/2)*(x₁+x₂) + ((r₁^2 - r₂^2)/(2*R^2))*(x₁+x₂) + 1/2*sqrt(2((r₁^2 + r₂^2)/R^2) - (r₁^2 - r₂^2)^2/R^4 - 1)*(x₁+x₂)
        x2 = (1/2)*(x₁+x₂) + ((r₁^2 - r₂^2)/(2*R^2))*(x₁+x₂) - 1/2*sqrt(2((r₁^2 + r₂^2)/R^2) - (r₁^2 - r₂^2)^2/R^4 - 1)*(x₁+x₂)
        y1 = (1/2)*(y₁+y₂) + ((r₁^2 - r₂^2)/(2*R^2))*(y₁+y₂) + 1/2*sqrt(2((r₁^2 + r₂^2)/R^2) - (r₁^2 - r₂^2)^2/R^4 - 1)*(y₁+y₂)
        y2 = (1/2)*(y₁+y₂) + ((r₁^2 - r₂^2)/(2*R^2))*(y₁+y₂) - 1/2*sqrt(2((r₁^2 + r₂^2)/R^2) - (r₁^2 - r₂^2)^2/R^4 - 1)*(y₁+y₂)

        return (x1, y1), (x2, y2)
    end
end



# I also want to get the area of overlap if they do overlap
# https://en.wikipedia.org/wiki/Circular_segment
function getOverlapArea(unit1::Unit, unit2::Unit)

    # check that they do overlap else complex lol
    if checkOverlap(unit1, unit2) ∉ ["overlap","swallow","swallowed"]
        # println("Units ", unit1.name, " and ", unit1.name, " do not overlap.")
        return 
    elseif checkOverlap(unit1, unit2) in ["swallow","swallowed"]
        return min(unit1.InfluenceRadius,unit2.InfluenceRadius)^2*π
    else

    r₁ = unit1.InfluenceRadius
    r₂ = unit2.InfluenceRadius
    x₁ = unit1.position[1]
    y₁ = unit1.position[2]
    x₂ = unit2.position[1]
    y₂ = unit2.position[2]

    d = sqrt((x₂ - x₁)^2 + (y₂ - y₁)^2)

    d₁ = (r₁^2 - r₂^2 + d^2)/(2*d)
    d₂ = d - d₁

    A₁ = r₁^2*acos(d₁/r₁) - d₁*sqrt(r₁^2 - d₁^2)
    A₂ = r₂^2*acos(d₂/r₂) - d₂*sqrt(r₂^2 - d₂^2)

    A = A₁ + A₂

    return A
    end

end

# ok, so I have the ways these lads overlap

# ok, so for the combat stage:

# 1) Find the areas that are overlapping 
# 2) the realitive density comparison. 
# 3) from the density, combat strength and morale, Calculate the losses suffered by each unit.
# 4) Once the losses have been calculated for all units, apply the losses to all units.

# 5) If a unit has lost 75% its soldiers, remove it from the game.
# 6) if a unit touches the center of another unit, it is also removed from the game??



# Will start with 3

# combat has several outcomes
    # begins with an overlap which creates a combat zone.
    # the combat zone has a density of soldiers which are compared w combat strength and morale. 
    # This translates into losses. Losses mean that the unit has less soldiers, which translates to less influence radius.      

    # we calculate the losses for each unit. the first unit being the one that is affected
rand(.8:.0001:1.2)


(2/(1+exp(-1*(100 -0))))

function calculateCombat!(unit1::Unit, unit2::Unit)



    # get the area of the compat zone. 
    A = getOverlapArea(unit1, unit2)

    if isnothing(A)
        return unit1
    else

    # get unit densit+ies 
    d₁ = unit1.soliderCnt/A
    d₂ = unit2.soliderCnt/A

    # compare the forces.
    # I pulled this formula out of my ass. I want ongoing combats to be rough, and I want combat strength to really matter
    logistic(x) = 5/(1+exp(-0.2(x  -0))) 

 

    pctInflicted = 
            logistic(( unit2.combatStrength - unit1.combatStrength) ) *
            unit1.morale * min(unit1.supplies/unit1.soliderCnt,1.2) *
            (1/(1+exp(-1*(d₂-d₁ -0)))+0.5) * 
            rand(.8:.0001:1.2)



    # pctSuppliesDestroyed = 0 # I want to add this in to make SpecOps a thing. 
    # suppliesGained = 0
    # If there is a high density diff, the smaller diff can make their supplies go further per casualty.
    suppliesConsumed = 1 + pctInflicted * d₁/ (d₁ + d₂)

    unit1.pctInflicted = pctInflicted
    unit1.suppliesConsumed = suppliesConsumed

    # println("d₁ - d₂ = ",d₂-d₁)
    # println("logistic(d₁ - d₂) = ",(2/(1+exp(-1*(d₂-d₁ -0)))))
    # println("pctInflicted = ",pctInflicted )

    return unit1
    end

end


function applyCombat!(unit::Unit)

    # Apply the combat strengtd changes
    CS = unit.soliderCnt * (1-unit.pctInflicted/100)
    unit.soliderCnt = max(round(CS),0)
    unit.pctInflicted = 0

    # Apply the supplies changes
    supplies = unit.supplies - unit.suppliesConsumed
    unit.supplies = max(supplies,0)
    unit.suppliesConsumed = 0

    # and check to see if the engagement radius has changed.
    changeInfluence!(unit,unit.InfluenceRadius)

    return unit

end


# basic func to plot units engaging
function plotUnits(u1::Unit, u2::Unit, i=0)

    f = Figure()
    Axis(f[1, 1], limits = ((-100, 100), (-100,100)))

    arc!(Point2f(u1.position[1], u1.position[2]), u1.InfluenceRadius, -π, π)
    arc!(Point2f(u2.position[1], u2.position[2]), u2.InfluenceRadius, -π, π)

    Label(f[0, 0], "rnd $i")
    f

end


# I want to be able to kill units if they have lost 75% of their soldiers
# or if morale is too low. TBD
# or if they are out of supplies and are being engaged.
# basically they just disappear if killed

function killCheck(u::Unit)
    if u.soliderCnt < 0.25*u.staringSoliderCnt
        println("Unit ", u.name, " has been killed.")
        return true
    else
        return false
    end
end

# j = unit("u1",combatStrength = 10,staringSoliderCnt= 1000, soliderCnt = 100, InfluenceRadius =



"""
Utility function for pulling out the ith unit from a list of units.
"""
function getUnit(activeUnits,i)
    return activeUnits[i]
end
"""
Utility function for putting a unit back into a list of units at point n
    """
function putUnit(activeUnits,i,u)
    activeUnits[i] = u
    return activeUnits
end

# Ok, so here we have some visualisation utilities:
function createArrow(x1,y1,x2,y2;barWidth=nothing,noseLength=nothing,arrowWidth=nothing)

    VectorLen = sqrt((x1-x2)^2 + (y1-y2)^2)
    UnitVector = ((x2-x1)/VectorLen , (y2-y1)/VectorLen)

    if isnothing(barWidth)
        barWidth = 1
    end

    if isnothing(noseLength)
        noseLength = 1
    end

    if isnothing(arrowWidth)
        arrowWidth = 2
    end

    poly = []

    push!(poly,Point2f(x2,y2))

    # Get the nose length, back from the tip, to find this midpoint
    ArrowMiddlePoint = (x2 - noseLength * UnitVector[1] , y2 - noseLength * UnitVector[2] ) 
    
    # println("Arrow from ($x1,$y1), ($x2,$y2)")
    # println("VectorLen = $VectorLen")
    # println("UnitVector = $UnitVector")
    # println("ArrowMiddlePoint = $ArrowMiddlePoint")

    perp = (-UnitVector[2],UnitVector[1])

    # get the arrowhead
    push!(poly, Point2f(ArrowMiddlePoint[1] - arrowWidth/2*perp[1], ArrowMiddlePoint[2] - arrowWidth/2*perp[2]))
    push!(poly, Point2f(ArrowMiddlePoint[1] - barWidth/2*perp[1], ArrowMiddlePoint[2] - barWidth/2*perp[2]))

    # get the tail of the arrowhead bar
    push!(poly, Point2f(x1 - barWidth/2*perp[1], y1 - barWidth/2*perp[2]))
    push!(poly, Point2f(x1 + barWidth/2*perp[1], y1 + barWidth/2*perp[2]))

    # and the other side of the arrowhead
    push!(poly, Point2f(ArrowMiddlePoint[1] + (barWidth/2)*perp[1], ArrowMiddlePoint[2] + (barWidth/2)*perp[2]))
    push!(poly, Point2f(ArrowMiddlePoint[1] + (arrowWidth/2)*perp[1], ArrowMiddlePoint[2] + (arrowWidth/2)*perp[2]))

    # and finish it off at the nose
    push!(poly,Point2f(x2,y2))

    # and make it point
    return Point2f.(poly)

end

function plotMap(activeUnits)

    f = Figure()
    Axis(f[1, 1], limits = ((-100, 100), (-100,100)))

    teamMap = Dict("team1" => "red", "team2" => "blue", "teamDev" => "pink")

    # plot the radias of influence for each unit 
    for o in to_value(activeUnits)
        i = to_value(o)
        arc!(i.position, i.InfluenceRadius, -π, π, color = teamMap[i.team], alpha = 0.5)
    end

    # plot the positions of the units 
    for o in activeUnits
        i = to_value(o)
        text!(
            i.position,
            text = i.name,
            color = teamMap[i.team],
            align = (:center, :center),
        )
    end

    # and plot the movement arrows
    for o in activeUnits
        i = to_value(o)
        # println(i.destination)
        if !ismissing(i.destination) || falseIfMissing(i.destination != i.position)
            # lines!(
            #     [i.position,
            #     i.destination],
            #     color = teamMap[i.team],
            # )
            # Add an arrowhead at the 'to' point
            poly!(createArrow(i.position[1] , i.position[2], i.destination[1],i.destination[2]; barWidth = 0.4,arrowWidth = 2, noseLength = 4  ), color = teamMap[i.team])
            # barWidth=nothing,noseLength=nothing,arrowWidth=nothing
        end
    end
    # string(i.name,"\n",i.type,"\n",i.team)
f
end


# add interactive map

function plotInteractiveMap(activeUnits)

    # create out observables? May need more?
    global activeUnits

    idx = Observable(1)
    ActiveO = Observable(activeUnits)
    CurrentUnit = @lift getUnit($ActiveO,$idx)
    
    teamMap = Dict("team1" => "red", "team2" => "blue", "teamDev" => "pink")
    speed_vals = [2, 4, 6, 8, 10, 20]
    
    teamColours = @lift [teamMap[i.team] for i in $ActiveO]
    teamUnitNames = @lift  [i.name for  i in $ActiveO]
    positions = @lift [i.position for i in $ActiveO]
    linePositions = @lift [(i.position,coalesce(i.destination,i.position)) for i in $ActiveO]

    currentObjectSpeed_i = Observable{Any}(0.0)

# When the current unit is updated, we need to update the menus
# println("current unit: ",CurrentUnit[])
    on(idx) do s
        println(typeof(s))
        println("selected unit: $idx")

        currentObjectSpeed_i = findfirst( ==(to_value(CurrentUnit).speed), speed_vals)
        speed__M.i_selected = currentObjectSpeed_i

    end
    
    # ok, so do the plotting things.
    # s = Scene(camera = campixel!, size = (800, 800))
    s = Figure(size = (1280, 800))
    # Axis(s[1, 1], limits = ((-100, 100), (-100,100)))
    ax = Axis(s[1, 2], limits = ((-150, 150), (-150,150)), aspect = 1)
    # println("interaction: ",interactions(ax))
    deregister_interaction!(ax, :rectanglezoom)
    # deregister_interaction!(ax, :dragpan)


    hidespines!(ax)

    # Lets add menus

    # when I select a unit, I want to be able to change the attributes of that unit.

    selectUnit__M = Menu(s,
        options = zip(to_value(teamUnitNames),collect(1:length(to_value(teamUnitNames)))),
        # selection = idx[]
        )
    
    on(selectUnit__M.selection) do s
        # println("selected unit: ",s)
        idx[] = s

    end

    # now I want to add attributes of the selected unit that we can change.
    # when IDX changes, this needs to update.

    speed__M = Menu(s,
        options = zip(string.("Speed ", speed_vals),collect(1:length(to_value(speed_vals)))),
        )   

    on(speed__M.selection) do s
    println("speed change: Changing Unit ",CurrentUnit[].name," speed to : ",CurrentUnit[].speed)
        cu = to_value(CurrentUnit)
        cu.speed = speed_vals[s]
        ActiveO[] = putUnit(activeUnits,idx[],cu)
    end
    

    s[1, 1] = vgrid!(
        Label(s, "Unit:", width = nothing), 
        selectUnit__M,
        Label(s, "Attributes:", width = nothing),
        speed__M
        ;
        tellheight = false, width = 200
        )

# Make the plots

    linesegments!(linePositions,  color = to_value(teamColours))
    scatter!(to_value(positions), strokewidth = 3,  color = to_value(teamColours))

    text!(to_value(positions), text = to_value(teamUnitNames), color = to_value(teamColours), align = (:center, :top))

    # and add area of influence
    # arc!(i.position, i.InfluenceRadius, -π, π, color = teamMap[i.team], alpha = 0.5)
    for i in activeUnits
        arc!(i.position, i.InfluenceRadius, -π, π, color = teamMap[i.team], alpha = 0.5)
    end

# Here are the keyboard interactions

    on(events(s).mousebutton, priority = 2) do event

        if event.button == Mouse.right && event.action == Mouse.press

            plt, i = GLMakie.pick(s,10)
            # println(plt)
            if plt isa Scatter{Tuple{Vector{Point{2, Float32}}}}
    
                selectUnit__M.i_selected = i 
            end
        end

        # println("positions: ",positions)

        # if event.button == Mouse.right && event.action == Mouse.press && idx[] != 0
        on(events(ax).mouseposition, priority = 3) do mp
            mb = events(s).mousebutton[]
            if mb.button == Mouse.left && mb.action == Mouse.press

                # get current unit and update destination
                cu = to_value(CurrentUnit)
                # println("current dest: ",cu.destination)
                cu.destination = Point2f(mouseposition(ax))
                CurrentUnit[] = cu

                # push it back unto the active Unit, and update Observable
                ActiveO[] = putUnit(activeUnits,idx[],cu)
                notify(ActiveO)

            end
        end

    end

    display(s)
    return to_value(ActiveO)
end


