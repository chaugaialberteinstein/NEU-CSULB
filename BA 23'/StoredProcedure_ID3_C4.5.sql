DELIMITER //

CREATE PROCEDURE CalculateEntropyAndGain(IN feature_column VARCHAR(255), OUT entropy FLOAT, OUT gain FLOAT)
BEGIN
    DECLARE total_count INT;
    DECLARE class_count INT;
    DECLARE class_freq FLOAT;
    DECLARE class_entropy FLOAT;
    DECLARE total_entropy FLOAT;
    DECLARE calculated_gain FLOAT;
    
    SET total_count = (SELECT COUNT(*) FROM data_table);
    SET calculated_gain = 0;
    
    -- Calculate total entropy
    SET total_entropy = 0;
    FOR class_val IN (SELECT DISTINCT class FROM data_table) DO
        SET class_count = (SELECT COUNT(*) FROM data_table WHERE class = class_val.class);
        SET class_freq = class_count / total_count;
        SET class_entropy = -1 * (class_freq * LOG2(class_freq));
        SET total_entropy = total_entropy + class_entropy;
    END FOR;

    -- Calculate feature-based entropy and gain
    FOR feature_val IN (SELECT DISTINCT feature_column FROM data_table) DO
        SET class_entropy = 0;
        FOR class_val IN (SELECT DISTINCT class FROM data_table) DO
            SET class_count = (SELECT COUNT(*) FROM data_table WHERE feature_column = feature_val.feature AND class = class_val.class);
            SET class_freq = class_count / total_count;
            IF class_freq > 0 THEN
                SET class_entropy = class_entropy - (class_freq * LOG2(class_freq));
            END IF;
        END FOR;

        SET calculated_gain = total_entropy - class_entropy;
        
        -- Update gain if calculated gain is greater than the current gain
        IF calculated_gain > gain THEN
            SET gain = calculated_gain;
            SET entropy = class_entropy;
        END IF;
    END FOR;

END //

DELIMITER ;
