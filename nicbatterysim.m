ratedcap = 260;
ratedcharge = 130;
threshhold = 230;
cap(1,1) = 0;

i = 1;
%CHARGE CASE
if cap(i-1,1) < ratedcap
    if cap(i-1,1) + pvkw < 260
        if pvkw < kwcap
            building.charge = pvkw;
        else
            building.charge = kwcap;
        end
    elseif cap(i-1,1) + pvkw >= 260
        if pvkw < kwcap
            building.charge = 260-cap(i-1,1);
        else
            building.charge = kwcap;
        end
    end
end

%DISCHARGE CASE
if loadkw >= threshhold
    if cap(i-1, 1) > ratedcap/2 %check if BL is above 50%
        if load-threshhold < kwcap %when discharge is not larger than rated power
            building.discharge = load-threshhold;
        else
            building.discharge = kwcap;
        end
    else %when the capacity is at 50% or lower
        building.discharge = 0;
    end
end

%BATTERY CAPACITY
if (charge/4)+(discharge/4) <= ratedcap
    cap(i, 1) = (charge/4)+(discharge/4)
else
    cap(i,1) = ratedcap

%NEW LOAD

