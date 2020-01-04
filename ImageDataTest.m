classdef ImageDataTest < matlab.unittest.TestCase
    properties
        id = ImageData().empty();
        A0 = logical([
            0   0   0   0   0
            0   0   1   0   0
            0   1   1   1   0
            0   0   1   0   0
            0   0   0   0   0
            1   1   1   1   1
            1   1   0   1   1
            1   0   0   0   1
            1   1   0   1   1
            1   1   1   1   1
            ]);
    end
    methods
        function obj = ImageDataTest()
            obj.id = ImageData('demo');
            obj.id.A = obj.A0;
        end
    end
    methods (Test)
        function testimagedata(tc)
            tc.assertEqual(tc.id.width, 5);
            tc.assertEqual(tc.id.height, 10);
            tc.assertTrue(tc.id.isbinary);
            tc.assertFalse(tc.id.isuint16);
        end
        
        function testissameimage(tc)
            tc.assertTrue(tc.id.issameimage(tc.id));
        end
            
        function testimXOR(tc)
            % imXOR(imagedata)
            % if both obj and imagedata are measured
            %   compute XOR of obj and imagedata
            %   redo measurement and return
            % else
            %   throw ImageData:imxor:NotLabeledGrayscale
            
            %case 1: imXOR of two unlabeled images
            tc.assertFalse(tc.id.ismeasured);
            tc.assertError(@()tc.id.imXOR(tc.id), 'ImageData:imxor:NotLabeledGrayscale');
                        
            %case 2: imXOR of two labeled imagedata
            id1 = tc.id.finddroplet();
            id2 = tc.id.invert().finddroplet();
            tc.assertTrue(id1.ismeasured && id2.ismeasured);
            id3 = id1.imXOR(id2);
            tc.assertTrue(id3.ismeasured);
            tc.assertEmpty(id3.measurements);  % a 5-by-10 droplet
            
            %case 3: imXOR of one labeled and one unlabeled imagedata
            id1 = tc.id; id1.A = double(id1.A);
            id2 = tc.id; id2 = id2.finddroplet();
            tc.assertTrue(~id1.ismeasured && id2.ismeasured);
            tc.assertError(@()id1.imXOR(id2), 'ImageData:imxor:NotLabeledGrayscale');
            
        end
        
        function testinvert(tc)
            %uint16 inversion
            id0 = tc.id;
            id1 = id0.invert();
            
            tc.assertFalse(id0.isinverted);
            tc.assertTrue(id1.isinverted);
            tc.assertEqual(range(id0.A, 'all'), range(id1.A, 'all'));
            
            %binary inversion
            id2 = id0.imbinarize(0.5);
            id3 = id2.invert();
            
            tc.assertEqual(sum(id3.A, 'all') + sum(id2.A, 'all'), numel(id0.A));
            tc.assertTrue(id3.isbinary);
        end
        
        function testImbinarize(tc)
            id = tc.id;
            % keep binary input unchanged
            tc.assertTrue(tc.id.isbinary);
            tc.assertEqual(tc.id.A, tc.id.imbinarize(0.5).A);
            
            % convert uint16 to binary
            id.A = uint16(id.A);
            tc.assertFalse(id.isbinary);
            id1 = id.imbinarize(0.5);
            tc.assertTrue(id1.isbinary);
            tc.assertEqual(sum(id1.A, 'all') + sum(~id1.A, 'all'), numel(id.A));
        end
        
        function testfinddroplet(tc)
            id1 = tc.id.finddroplet();
            id2 = tc.id.finddroplet(DropletParams());
            % by default it should use default DropletParams()
            tc.assertTrue(id1.ismeasured);
            tc.assertTrue(id2.ismeasured);
            % it should setup a non-empty measurement
            tc.assertNotEmpty(id1.measurements);
            % id and id.invert() should return same measurement
            tc.assertEqual(tc.id.finddroplet().measurements, ...
                tc.id.invert().finddroplet().measurements);
        end
        
        
        function testgetpc(tc)
            tc.id.A = tc.A0;
            tc.assertEqual(tc.id.getpc(), 0.5000);
            tc.id.A = double(tc.A0)*10000;
            tc.assertEqual(tc.id.getpc(), 0.5000);
        end
    end
end