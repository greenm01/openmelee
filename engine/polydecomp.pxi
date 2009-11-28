def decompose_poly(Polygon poly):

    Point upperInt, lowerInt, p, closestVert
    Scalar upperDist, lowerDist, d, closestDist
    int upper_index, lower_index, closest_index
    Polygon lower_poly, upper_poly

    for i in range(len(poly)):
        if isReflex(poly, i):
            reflexVertices.append(poly[i])
            upperDist = lowerDist = numeric_limits<Scalar>::max()
            for j in range(len(poly)):
                if left(at(poly, i - 1), at(poly, i), at(poly, j) and rightOn(at(poly, i - 1), at(poly, i), at(poly, j - 1)):
                    # if line intersects with an edge
                    # find the point of intersection
                    p = intersection(at(poly, i - 1), at(poly, i), at(poly, j), at(poly, j - 1)) 
                    if right(at(poly, i + 1), at(poly, i), p): 
                        # make sure it's inside the poly
                        d = sqdist(poly[i], p)
                        if d < lowerDist: 
                            # keep only the closest intersection
                            lowerDist = d
                            lowerInt = p
                            lower_index = j
                if left(at(poly, i + 1), at(poly, i), at(poly, j + 1) and rightOn(at(poly, i + 1), at(poly, i), at(poly, j)):
                    p = intersection(at(poly, i + 1), at(poly, i), at(poly, j), at(poly, j + 1))
                    if left(at(poly, i - 1), at(poly, i), p):
                        d = sqdist(poly[i], p)
                        if d < upperDist:
                            upperDist = d
                            upperInt = p
                            upper_index = j

            # if there are no vertices to connect to, choose a point in the middle
            if lower_index == (upper_index + 1) % len(poly):
                p.x = (lowerInt.x + upperInt.x) / 2
                p.y = (lowerInt.y + upperInt.y) / 2
                steinerPoints.append(p)

                if i < upper_index:
                    lower_poly.insert(lower_poly[-1], poly[0] + i, poly[0] + upper_index + 1)
                    lower_poly.append(p)
                    upper_poly.append(p)
                    if (lower_index != 0) upper_poly.insert(upper_poly[-1], poly[0] + lower_index, poly[-1])
                    upper_poly.insert(upper_poly[-1], poly[0], poly[0] + i + 1)
                else:
                    if (i != 0) lower_poly.insert(lower_poly[-1], poly[0] + i, poly[-1])
                    lower_poly.insert(lower_poly[-1], poly[0], poly[0] + upper_index + 1)
                    lower_poly.append(p)
                    upper_poly.append(p)
                    upper_poly.insert(upper_poly[-1], poly[0] + lower_index, poly[0] + i + 1)
            else:
            
                # connect to the closest point within the triangle

                if lower_index > upper_index:
                    upper_index += len(poly)
                
                closestDist = numeric_limits<Scalar>::max()
                for (int j = lower_index j <= upper_index ++j:
                    if leftOn(at(poly, i - 1), at(poly, i), at(poly, j) and rightOn(at(poly, i + 1), at(poly, i), at(poly, j)):
                        d = sqdist(at(poly, i), at(poly, j))
                        if d < closestDist:
                            closestDist = d
                            closestVert = at(poly, j)
                            closest_index = j % len(poly)

                if i < closest_index:
                    lower_poly.insert(lower_poly[-1], poly[0] + i, poly[0] + closest_index + 1)
                    if closest_index != 0: 
                        upper_poly.insert(upper_poly[-1], poly[0] + closest_index, poly[-1])
                    upper_poly.insert(upper_poly[-1], poly[0], poly[0] + i + 1)
                else:
                    if i != 0:
                        lower_poly.insert(lower_poly[-1], poly[0] + i, poly[-1])
                    lower_poly.insert(lower_poly[-1], poly[0], poly[0] + closest_index + 1)
                    upper_poly.insert(upper_poly[-1], poly[0] + closest_index, poly[0] + i + 1)
  
            # solve smallest poly first
            if len(lower_poly) < len(upper_poly):
                decompose_poly(lower_poly)
                decompose_poly(upper_poly)
            else:
                decompose_poly(upper_poly)
                decompose_poly(lower_poly)
            
            return

    polys.append(poly)

cdef at(vector<T> v, int i):
    return v[wrap(i, v.size())]
    
cdef wrap(int a, int b):
    return (a % b + b) if a < 0 else a % b
