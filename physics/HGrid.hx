/*
 * Copyright (c) 2009, Mason Green 
 * http://github.com/zzzzrrr/haxmel
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the polygonal nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package physics;

import haxe.FastList;

import utils.Vec2;

typedef Cell = {
    var x : Int;
    var y : Int;
    var z : Int;
}
     
class HGrid extends BroadPhase
{

    public static var CELL_TO_CELL_RATIO = 2.0; 
    public static var SPHERE_TO_CELL_RATIO = 0.25;
    public static var MIN_CELL_SIZE = 10;
    static var NUM_BUCKETS  = 1024;
    static var HGRID_MAX_LEVELS = 32;

    var occupiedLevelsMask : Int; 
    var objectsAtLevel : Array<Int>; 
    var objectBucket : Array<Body>; 
    var timeStamp : Array<Int>;  
    var tick : Int;
     
     public function new(bodyList : FastList<Body>) {
         super(bodyList);
     }

    static function hashIndex(cellPos:Cell) : Int {
        var h1 : Int = 0x8da6b343; 
        var h2 : Int = 0xd8163841; 
        var h3 : Int = 0xcb1ab31f;
        var n = h1 * cellPos.x + h2 * cellPos.y + h3 * cellPos.z;
        n = n % NUM_BUCKETS;
        if (n < 0) n += NUM_BUCKETS;
        return n;
    }

    public function update() {
        for(rb in m_bodyList) {
            var cellPos : Cell = {x:Std.int(rb.pos.x / rb.size), y:Std.int(rb.pos.y / rb.size), z:rb.level};
            var bucket : Int = hashIndex(cellPos);
            rb.bucket = bucket;
            rb.next = objectBucket[bucket];
            objectBucket[bucket] = rb;
            objectsAtLevel[rb.level]++;
            occupiedLevelsMask |= (1 << rb.level);
        }
    }

    // Test collisions between objects in hgrid
    public function commit() {
        
        var size = MIN_CELL_SIZE;
        var startLevel = 0;
        var occupiedLevelsMask = this.occupiedLevelsMask;
        
        for(rb in m_bodyList) {
            
            var pos = rb.pos;
            var diameter = rb.diameter;
            while(size * SPHERE_TO_CELL_RATIO < diameter) {
                size *= Std.int(CELL_TO_CELL_RATIO);
                occupiedLevelsMask >>= 1;
                startLevel++;
            }

            tick++;
            var level = startLevel;
            while(level < HGRID_MAX_LEVELS) {
                
                if (occupiedLevelsMask == 0) break;
                if ((occupiedLevelsMask & 1) == 0) continue;
                
                var delta = rb.radius + size * SPHERE_TO_CELL_RATIO + Vec2.EPSILON;
                var ooSize = 1.0 / size;
                var x1 = Std.int(Math.floor((pos.x - delta) * ooSize));
                var y1 = Std.int(Math.floor((pos.y - delta) * ooSize));
                var x2 = Std.int(Math.ceil((pos.x + delta) * ooSize));
                var y2 = Std.int(Math.ceil((pos.y + delta) * ooSize));
                
                for (x in x1...x2+1) {
                    for (y in y1...y2+1) {
                        
                        var cellPos : Cell = {x:x, y:y, z:level};
                        var bucket = hashIndex(cellPos);
                        
                        if (timeStamp[bucket] == tick) continue;
                        timeStamp[bucket] = tick;
                        
                        var p = objectBucket[bucket];
                        while (p != null) {
                            if (p != rb) {
                                // Circle circle check
                                var d = pos.sub(p.pos);
                                var dist2 = d.dot(d);
                                var radiusSum = rb.radius + p.radius;
                                if(dist2 <= radiusSum * radiusSum) {
                                    //callback(obj, p);
                                }
                            }
                            p = p.next;
                        }
                    }
                }
                size *= Std.int(CELL_TO_CELL_RATIO);
                occupiedLevelsMask >>= 1; 
                level++;
            }
        } 
    }
}
