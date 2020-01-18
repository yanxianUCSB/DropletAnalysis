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
            %A.invert()
            % case 1: A.isbinary
            %     negation
            % case 2: A.isuint16
            %     2^16 - A
            % else:
            %       throw NotUint16orBinary
            
            %case 1: binary inversion
            id0 = tc.id;
            id1 = id0.invert();
            tc.assertFalse(id0.isinverted);
            tc.assertTrue(id1.isinverted);
            tc.assertEqual(sum(id1.A, 'all') + sum(id0.A, 'all'), numel(id0.A));
            tc.assertTrue(id1.isbinary);
            
            %case 2: uint16 inversion
            id0 = tc.id; id0.A = uint16(id0.A * 2^16);
            id1 = id0.invert();
            tc.assertEqual(id0.A + id1.A, 2^16 * uint16(ones(size(id0.A))));
            tc.assertTrue(id1.isuint16);
            
            %else
            id0 = tc.id; id0.A = id0.A * 2;
            tc.assertError(@()id0.invert(), 'ImageData:invert:NotUint16orBinary');
        end
        
        function teststretchlim(tc)
            %A.stretchlim()
            % case 1: if isuint16:
            %           use the top and bottom 1% intensity to stretch A
            % else:
            %       throw ImageData:NotUint16orBinary
            
            % case 1:
            id0 = tc.id;
            id0.A = uint16(reshape(1:100, 10, 10));
            id1 = id0.stretchlim();
            tc.assertEqual(id1.A(1:2), uint16([0, 0]));
            tc.assertEqual(id1.A(end-1:end), uint16([65535, 65535]));
            
            % case 2:
            tc.assertTrue(tc.id.isbinary);
            
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