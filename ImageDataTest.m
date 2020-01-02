classdef ImageDataTest < matlab.unittest.TestCase
    properties
        id = ImageData().empty();
    end
    methods 
        function obj = ImageDataTest()
            obj.id = ImageData('demo');
        end
    end
    methods (Test)
        function testInvert(tc)
            id0 = tc.id;
            id1 = id0.invert();

            tc.assertFalse(id0.isinverted);
            tc.assertTrue(id1.isinverted);
            tc.assertEqual(range(id0.A, 'all'), range(id1.A, 'all'));
            
            id2 = id0.imbinarize(0.5);
            id3 = id2.invert();
            
            tc.assertEqual(sum(id3.A, 'all') + sum(id2.A, 'all'), numel(id0.A));
        end
        
        function testImbinarize(tc)
            id = tc.id;
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
            
            % successive call of finddroplet should keep identical
            id3 = id1.finddroplet();
            tc.assertEqual(numel(id1.measurements), numel(id3.measurements));
        end
        
        function testimOR(tc)
            id1 = tc.id.finddroplet();
            id2 = tc.id.invert().finddroplet();
            id3 = id1.imOR(id2);
            n1 = numel(id1.measurements);
            n2 = numel(id2.measurements);
            n3 = numel(id3.measurements);
            tc.assertEqual(n3, 1531);
            tc.assertLessThanOrEqual((n3 - n1 - n2) / mean([n3, n1+n2]), 0.005);
        end
    end
end